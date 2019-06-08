import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tatoolxp/models/tatool_user.dart';
import 'package:tatoolxp/models/app_state.dart';
import 'package:tatoolxp/actions/actions.dart';
import 'package:tatoolxp/middleware/authentication.dart';
import 'package:tatoolxp/presentation/module_view_model.dart';
import 'package:tatoolxp/presentation/loading_indicator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';

class ModuleScreen extends StatefulWidget {
  final FlutterLocalNotificationsPlugin notificationPlugin;
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final TatoolUser user;

  ModuleScreen(
      {Key key,
      @required this.notificationPlugin,
      this.auth,
      this.user,
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

  _launchPrivacyPolicy() async {
    const url = 'https://www.tatool-web.com/#/doc/about-privacy-policy.html';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Tatool XP'),
        ),
        endDrawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              new UserAccountsDrawerHeader(
                accountName: new Text('Tatool ID: ' + widget.user.tatoolId,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                accountEmail: Text(widget.user.email),
                currentAccountPicture: CircleAvatar(
                  child: new LayoutBuilder(builder: (context, constraint) {
                    return new Icon(
                      Icons.account_circle,
                      size: constraint.biggest.height,
                      color: Colors.red,
                    );
                  }),
                  backgroundColor: Colors.white,
                ),
              ),
              ListTile(
                leading: Icon(Icons.power_settings_new),
                title: Text('Logout'),
                onTap: () async {
                  Navigator.of(context).pop();
                  bool logout = await _confirmLogoutDialog(context);
                  if (logout) {
                    _signOut();
                  }
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.lock_outline),
                title: Text('Privacy Policy'),
                onTap: () {
                  _launchPrivacyPolicy();
                },
              ),
              ListTile(
                leading: Icon(Icons.cancel),
                title: Text('Close'),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) => SafeArea(
                child: Container(
                  color: Colors.white,
                  child: StoreConnector<AppState, ModuleViewModel>(
                    onInit: (store) {
                      store.dispatch(LoadModules(widget.user.userId));
                    },
                    converter: (store) => ModuleViewModel.fromStore(store),
                    builder: (context, viewModel) => (viewModel.loading)
                        ? LoadingIndicator()
                        : Stack(
                            children: <Widget>[
                              viewModel.modules.length == 0
                                  ? Positioned(
                                      top: constraints.maxHeight - 160,
                                      left: constraints.maxWidth - 250,
                                      child: Image.asset(
                                          'assets/tatool_hint_add_module.gif'),
                                      width: 170,
                                      height: 140,
                                    )
                                  : content(viewModel),
                            ],
                          ),
                  ),
                ),
              ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            String invitationCode = await _addModuleDialog(context);
            if (!(invitationCode?.isEmpty ?? false)) {
              StoreProvider.of<AppState>(context)
                  .dispatch(AddModule(widget.user.userId, invitationCode));
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
              vm.deleteModule(widget.user.userId, index);
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
                                moduleId: vm.modules[index].moduleId,
                                tatoolId: widget.user.tatoolId,
                              )));
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
              child: Text('OK', style: TextStyle(color: Colors.black)),
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
        return SingleChildScrollView(
          child: AlertDialog(
            title: Text('Add Module'),
            content: ListBody(
              children: <Widget>[
                Text('Enter your Invitation Code:'),
                TextField(
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  maxLength: 8,
                  controller: myController,
                ),
              ],
            ),
            actions: <Widget>[
              OutlineButton(
                child:
                    const Text('CANCEL', style: TextStyle(color: Colors.black)),
                onPressed: () {
                  Navigator.pop(context, '');
                },
              ),
              OutlineButton(
                child: const Text('OK', style: TextStyle(color: Colors.black)),
                onPressed: () {
                  Navigator.pop(context, myController.text);
                },
              )
            ],
          ),
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
              child: const Text('NO', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            OutlineButton(
              child: const Text('YES', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.pop(context, true);
              },
            )
          ],
        );
      },
    );
  }

  Future<bool> _confirmLogoutDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            OutlineButton(
              child: const Text('NO', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            OutlineButton(
              child: const Text('YES', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.pop(context, true);
              },
            )
          ],
        );
      },
    );
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
  final String tatoolId;

  TatoolWebView({Key key, @required this.moduleId, @required this.tatoolId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String url = 'https://www.tatool-web.com/#/public/' +
        this.moduleId +
        '?extid=' +
        this.tatoolId;
    print(url);

    return Container(
        child: WebView(
      initialUrl: url,
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
