import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rooster/common/log.dart';
import 'package:rooster/common/user.dart';
import 'package:open_file/open_file.dart';
import 'package:rooster/common/utils.dart';
import 'package:uuid/uuid.dart';
import 'package:workmanager/workmanager.dart';


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
  updateStatus([bool status]) async {
    if (status != null)
      await user.setAutoReport(status);
    setState(() {});
  }

  void onAutoReportChange(enabled) async {
    updateStatus(enabled);
    if (enabled) {
      await Workmanager.registerPeriodicTask('RoosterTask_${Uuid().v4()}', 'RoosterTask',
          tag: 'RoosterTask',
          constraints: Constraints(
              networkType: NetworkType.connected,
              requiresBatteryNotLow: false,
              requiresCharging: false,
              requiresDeviceIdle: false,
              requiresStorageNotLow: false
          ));
    } else {
      await Workmanager.cancelByTag('RoosterTask');
    }
  }


}
