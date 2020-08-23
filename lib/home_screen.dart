import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rooster/common/log.dart';
import 'package:rooster/common/user.dart';
import 'package:open_file/open_file.dart';
import 'package:rooster/common/utils.dart';
import 'package:background_fetch/background_fetch.dart';


class AppDrawer extends StatelessWidget {
  final User user;

  AppDrawer(this.user);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(user.userId),
            decoration: BoxDecoration(
              color: Colors.yellow,
            ),
          ),
          ListTile(
            title: Text('Home'),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx)=> HomePage(user: user,)));
            },
          ),
          ListTile(
            title: Text('Log'),
            onTap: () {
              getFilePath(logFileName).then((filePath) {
                print(filePath);
                try {
                  OpenFile.open(
                      filePath, type: "text/plain",
                      uti: "public.plain-text");
                }
                catch (ex) {
                  appLog.e('Could not open log', ex);
                }
              });
            },
          ),
        ],
      ),
    );
  }
}



class HomePage extends StatefulWidget {
  final User user;
  HomePage({Key key, @required this.user}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User user;
  int _status = 0;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    updateStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: AppDrawer(user),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Chip(label: Text(user.autoReport ? 'autoReport: Enabled' : 'autoReport: Disabled', style: TextStyle(fontSize: 32)), backgroundColor: user.autoReport ? Colors.green : Colors.red,),
              Chip(label: Text('Status: $_status', style: TextStyle(fontSize: 32),)),
              MaterialButton(child: Text('Configure'), color: Colors.yellow[700], onPressed: () async {
                await configureScheduledTask((s){
                  appLog.i('reported at ${DateTime.now()}');
                });
                await user.setAutoReport(true);
                await updateStatus();
              },),
              Switch(value: user.autoReport, onChanged: onAutoReportChange,),
              MaterialButton(child: Text('Clear Log'), color: Colors.yellow[700], onPressed: () async {
                final filePath = await getFilePath(logFileName);
                final f = File(filePath);
                f.writeAsStringSync('');
              },)
            ]
        ),
      ),
    );
  }
  updateStatus() async {
    int status = await BackgroundFetch.status;
    setState(() {
      _status = status;
    });
  }

  void onAutoReportChange(enabled) async {
    await user.setAutoReport(enabled);
    setState(() {});
    if (enabled) {
      await BackgroundFetch.start().then((int status) {
        appLog.i('[BackgroundFetch] start success: $status');
      }).catchError((e) {
        appLog.e('[BackgroundFetch] start FAILURE: $e');
      });
    } else {
      await BackgroundFetch.stop().then((int status) {
        appLog.i('[BackgroundFetch] stop success: $status');
      });
    }
    await updateStatus();
  }


}
