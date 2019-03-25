import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:redux_logging/redux_logging.dart';
import 'package:tatoolxp/models/models.dart';
import 'package:tatoolxp/reducers/app_state_reducer.dart';
import 'package:tatoolxp/presentation/root_page.dart';
import 'package:tatoolxp/middleware/module_middleware.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tatoolxp/middleware/authentication.dart';

var notificationPlugin;

void main() async {
  // disable top status bar
  SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);

  // initialise local notifications
  notificationPlugin = new FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid =
      new AndroidInitializationSettings('app_icon');
  var initializationSettingsIOS =
      new IOSInitializationSettings(onDidReceiveLocalNotification: null);
  var initializationSettings = new InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  notificationPlugin.initialize(initializationSettings,
      onSelectNotification: null);

  var store = await createStore();
  runApp(new TatoolApp(store));
}

Future<Store<AppState>> createStore() async {
  return Store<AppState>(
    appReducer,
    initialState: AppState.initial(),
    middleware: []
      ..add(LoggingMiddleware.printer())
      ..addAll(createModuleMiddleware(notificationPlugin)),
  );
}

class TatoolApp extends StatefulWidget {
  final Store<AppState> store;

  TatoolApp(this.store);
  @override
  _TatoolAppState createState() => _TatoolAppState();
}

class _TatoolAppState extends State<TatoolApp> {
  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: widget.store,
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: RootPage(
              auth: Auth(), notificationPlugin: notificationPlugin),
          theme: ThemeData(
            primaryColor: Colors.red,
          ),
          routes: <String, WidgetBuilder>{}),
    );
  }
}
