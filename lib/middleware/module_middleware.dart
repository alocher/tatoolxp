import 'dart:async';
import 'dart:math';

import 'package:redux/redux.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tatoolxp/models/app_state.dart';
import 'package:tatoolxp/actions/actions.dart';
import 'package:tatoolxp/models/module.dart';
import 'package:tatoolxp/models/notification.dart';
import 'package:tatoolxp/models/schedule.dart';

final _random = new Random();

FlutterLocalNotificationsPlugin notificationPlugin;

List<Middleware<AppState>> createModuleMiddleware(
    FlutterLocalNotificationsPlugin plugin) {
  notificationPlugin = plugin;

  final initModule = _initModule();
  final loadModules = _loadModules();
  final deleteModule = _deleteModule();
  final addModule = _addModule();

  return [
    TypedMiddleware<AppState, StartModule>(initModule),
    TypedMiddleware<AppState, LoadModules>(loadModules),
    TypedMiddleware<AppState, DeleteModule>(deleteModule),
    TypedMiddleware<AppState, AddModule>(addModule),
  ];
}

Middleware<AppState> _loadModules() {
  return (Store<AppState> store, action, NextDispatcher next) async {
    store.dispatch(Actions.ShowWaitIndicator);
    List<Module> modules = await _dbGetModules(action.userId);
    store.dispatch(ModulesLoaded(modules));
  };
}

Middleware<AppState> _addModule() {
  return (Store<AppState> store, action, NextDispatcher next) async {
    store.dispatch(Actions.ShowWaitIndicator);
    if (store.state.modules.length > 0) {
      Module module = store.state.modules.firstWhere(
          (module) => module.invitationCode == action.invitationCode,
          orElse: () => null);
      if (module == null) {
        List<Module> modules =
            await _dbAddModule(action.userId, action.invitationCode);
        if (modules != null) {
          store.dispatch(ModulesLoaded(modules));
        } else {
          store.dispatch(Actions.HideWaitIndicator);
        }
      } else {
        store.dispatch(Actions.HideWaitIndicator);
      }
    } else {
      List<Module> modules =
          await _dbAddModule(action.userId, action.invitationCode);
      if (modules != null) {
        store.dispatch(ModulesLoaded(modules));
      } else {
        store.dispatch(Actions.HideWaitIndicator);
      }
    }
  };
}

Middleware<AppState> _deleteModule() {
  return (Store<AppState> store, action, NextDispatcher next) async {
    store.dispatch(Actions.ShowWaitIndicator);
    List<Module> modules = await _dbDeleteModule(action.userId, action.index);
    store.dispatch(ModulesLoaded(modules));
  };
}

Middleware<AppState> _initModule() {
  return (Store<AppState> store, action, NextDispatcher next) {
    Future.delayed(new Duration(seconds: 5), () {
      store.dispatch(Actions.HideWaitIndicator);
    });
    next(action);
  };
}

Future<List<Module>> _dbGetModules(String userId) async {
  DocumentSnapshot documentSnapshot =
      await Firestore.instance.collection('users').document(userId).get();

  if (documentSnapshot.exists && documentSnapshot.data['modules'] is List) {
    return List<Module>.from(documentSnapshot.data['modules']
        .map((snapshot) => Module.fromMap(Map<String, dynamic>.from(snapshot)))
        .toList());
  }
  return [];
}

Future<List<Module>> _dbAddModule(String userId, String invitationCode) async {
  var modules = [];

  DocumentSnapshot moduleSnapshot = await Firestore.instance
      .collection('modules')
      .document(invitationCode)
      .get();

  if (!moduleSnapshot.exists) {
    return null;
  }

  List<Notification> notifications = _createNotifications(
      invitationCode,
      Schedule.fromMap(
          Map<String, dynamic>.from(moduleSnapshot.data['schedule'])));
  moduleSnapshot.data['invitationCode'] = invitationCode;
  moduleSnapshot.data['notifications'] =
      notifications.map((note) => note.toMap()).toList();
  Module module = Module.fromMap(moduleSnapshot.data);

  await _scheduleNotifications(notifications);

  final DocumentReference userRef =
      Firestore.instance.collection('users').document(userId);

  return Firestore.instance.runTransaction((Transaction tx) async {
    DocumentSnapshot snapshot = await tx.get(userRef);
    modules = List<Map>.from(snapshot.data['modules']);

    if (snapshot.exists) {
      await tx.update(snapshot.reference, <String, dynamic>{
        'modules': FieldValue.arrayUnion([module.toMap()])
      });
    }
  }).then((result) {
    List<Module> t = List<Module>.from(modules
        .map((snapshot) => Module.fromMap(Map<String, dynamic>.from(snapshot)))
        .toList());
    t.add(module);
    return t;
  });
}

Future<List<Module>> _dbDeleteModule(String userId, int index) async {
  var modules = [];

  final DocumentReference docRef =
      Firestore.instance.collection('users').document(userId);

  return Firestore.instance.runTransaction((Transaction tx) async {
    DocumentSnapshot snapshot = await tx.get(docRef);
    modules = List<Map>.from(snapshot.data['modules']);

    if (snapshot.exists) {
      Module module = Module.fromMap(Map<String, dynamic>.from(modules[index]));
      await _cancelNotifications(module.notifications);

      modules.removeAt(index);
      await tx
          .update(snapshot.reference, <String, dynamic>{'modules': modules});
    }
  }).then((result) {
    return List<Module>.from(modules
        .map((snapshot) => Module.fromMap(Map<String, dynamic>.from(snapshot)))
        .toList());
  });
}

List<Notification> _createNotifications(
    String invitationCode, Schedule schedule) {
  List<Notification> notifications = [];

  if (schedule.scheduleType == 'daily') {
    notifications = _createDailyNotifications(invitationCode, schedule);
  }
  return notifications;
}

_cancelNotifications(List<Notification> notifications) async {
  notifications.forEach((notification) => notificationPlugin.cancel(notification.notificationId));
  notificationPlugin.cancel(0);
}

List<Notification> _createDailyNotifications(
    String invitationCode, Schedule schedule) {
  List<Notification> notifications = [];
  bool isDone = false;
  int numDays = 0;
  DateTime currentDate = new DateTime.now();
  int validTime = schedule.endTime - schedule.startTime;
  int validTimeBySlot = validTime ~/ schedule.numNotifications;
  int notificationCounter = 0;

  while (!isDone) {
    currentDate = currentDate.add(Duration(days: 1));
    if (schedule.scheduleWeekdays.contains((currentDate.weekday))) {
      numDays = numDays + 1;
      int previousHour = 0;
      for (int i = 0; i < schedule.numNotifications; i++) {
        notificationCounter++;
        int slotStartTime;
        if (i == 0) {
          slotStartTime = schedule.startTime + (i * validTimeBySlot);
        } else {
          slotStartTime = max(schedule.startTime + (i * validTimeBySlot),
              previousHour + schedule.intervalHours);
        }

        int hour = slotStartTime +
            _random.nextInt((slotStartTime + validTimeBySlot) - slotStartTime);
        int minute = _random.nextInt(60);
        Notification note = Notification(
            notificationId: int.parse(invitationCode) + notificationCounter,
            notificationTime: DateTime(currentDate.year, currentDate.month,
                currentDate.day, hour, minute),
            notificationMessage: 'It\'s time for your Tatool Session!');
        notifications.add(note);
        previousHour = hour;
      }
    }

    if (numDays == schedule.scheduleNumDays) {
      isDone = true;
    }
  }
  return notifications;
}

_scheduleNotifications(List<Notification> notifications) async {
  for (int i = 0; i < notifications.length; i++) {
    var scheduledNotificationDateTime = notifications[i].notificationTime;
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'tatoolxp', 'Tatool XP', 'Tatool XP Notifications',
        importance: Importance.Max, priority: Priority.High, ongoing: false, autoCancel: true);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await notificationPlugin.schedule(
        notifications[i].notificationId,
        'Tatool XP',
        notifications[i].notificationMessage,
        scheduledNotificationDateTime,
        platformChannelSpecifics);
  }

  // one time demo notification
  var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'tatoolxp', 'Tatool XP', 'Tatool XP Notifications',
        importance: Importance.Max, priority: Priority.High, ongoing: false, autoCancel: true);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  notificationPlugin.schedule(0, 'Tatool XP', 'Module has been added successfully!', DateTime.now().add(Duration(seconds: 5)), platformChannelSpecifics);
}
