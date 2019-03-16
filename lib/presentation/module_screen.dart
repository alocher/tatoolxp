import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tatoolxp/models/app_state.dart';
import 'package:tatoolxp/actions/actions.dart';
import 'package:tatoolxp/middleware/authentication.dart';
import 'package:tatoolxp/presentation/module_view_model.dart';
import 'package:tatoolxp/presentation/loading_indicator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ModuleScreen extends StatefulWidget {
  final FlutterLocalNotificationsPlugin notificationPlugin;
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;

  ModuleScreen(
      {Key key,
      @required this.notificationPlugin,
      this.auth,
      this.userId,
      this.onSignedOut})
      : super(key: key);
  @override
  _ModuleScreenState createState() => _ModuleScreenState();
}

class _ModuleScreenState extends State<ModuleScreen> {
  @override
  void initState() {
    super.initState();
  }

  _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Tatool XP'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.power_settings_new),
              onPressed: _signOut,
            )
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) => SafeArea(
                child: Container(
                  color: Colors.white,
                  child: StoreConnector<AppState, ModuleViewModel>(
                    onInit: (store) {
                      store.dispatch(LoadModules(widget.userId));
                    },
                    converter: (store) => ModuleViewModel.fromStore(store),
                    builder: (context, viewModel) => (viewModel.loading)
                        ? LoadingIndicator()
                        : content(viewModel),
                  ),
                ),
              ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            String invitationCode = await _addModuleDialog(context);
            if (!(invitationCode?.isEmpty ?? false)) {
              StoreProvider.of<AppState>(context).dispatch(AddModule(widget.userId, invitationCode));
            }
          },
          child: Icon(
            Icons.add,
          ),
          backgroundColor: Colors.red,
        ),
      );

  Widget content(ModuleViewModel vm) => ListView.builder(
      itemCount: vm.modules.length,
      itemBuilder: (context, index) {
        var dismissible = Dismissible(
            key: new Key(vm.modules[index].moduleId),
            direction: DismissDirection.horizontal,
            onDismissed: (DismissDirection direction) {
              vm.deleteModule(widget.userId, index);
            },
            confirmDismiss: (DismissDirection direction) async {
              return await _deleteModuleDialog(context);
            },
            child: Card(
              elevation: 2.0,
              margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
              child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
                  leading: Container(
                    padding: EdgeInsets.only(right: 12.0),
                    decoration: new BoxDecoration(
                        border: new Border(
                            right: new BorderSide(
                                width: 1.0, color: Colors.black45))),
                    child:
                        Icon(Icons.play_circle_outline, color: Colors.black54),
                  ),
                  title: Text(
                    '${vm.modules[index].moduleName}',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  )),
            ));
        return new InkWell(
            onTap: () {
              //_showNotification();
              checkConnectivity().then((bool connected) {
                if (connected) {
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => TatoolWebView(
                              moduleId: vm.modules[index].moduleId)));
                } else {
                  _alertDialog(context);
                }
              });
            },
            child: dismissible);
      });

  _alertDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error Loading Module'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'The Server could not be reached. Make sure you are connected to the Internet and try again.'),
              ],
            ),
          ),
          actions: <Widget>[
            OutlineButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _addModuleDialog(BuildContext context) {
    final myController = new TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Module'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Enter your Invitation Code:'),
                TextField(autofocus: true, keyboardType: TextInputType.number, maxLength: 8, controller: myController,),
              ],
            ),
          ),
          actions: <Widget>[
            OutlineButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context, '');
              },
            ),
            OutlineButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context, myController.text);
              },
            )
          ],
        );
      },
    );
  }

  Future<bool> _deleteModuleDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Module'),
          content: const Text('Are you sure you want to delete this Module?'),
          actions: <Widget>[
            OutlineButton(
              child: const Text('NO'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            OutlineButton(
              child: const Text('YES'),
              onPressed: () {
                Navigator.pop(context, true);
              },
            )
          ],
        );
      },
    );
  }

  Future _showNotification() async {
    var scheduledNotificationDateTime =
        new DateTime.now().add(new Duration(seconds: 10));
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ongoing: true);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await widget.notificationPlugin.schedule(
        0,
        'scheduled title',
        'scheduled body',
        scheduledNotificationDateTime,
        platformChannelSpecifics);
  }

  Future<bool> checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        return true;
      }
    } on SocketException catch (_) {
      print('not connected');
      return false;
    }

    return false;
  }
}

class TatoolWebView extends StatelessWidget {
  final String moduleId;

  TatoolWebView({Key key, @required this.moduleId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: WebView(
      initialUrl:
          'https://www.tatool-web.com/#/public/' + this.moduleId + '?extid=666',
      javascriptMode: JavascriptMode.unrestricted,
      javascriptChannels: Set()
        ..add(JavascriptChannel(
            name: 'TatoolXP',
            onMessageReceived: (JavascriptMessage message) {
              print(message.message);
              if (message.message == 'sessionEnd') {
                Navigator.pop(context);
              }
            })),
    ));
  }
}
