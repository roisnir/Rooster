import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rooster/common/log.dart';
import 'package:rooster/login_page.dart';
import 'package:rooster/home_screen.dart';
import 'package:rooster/common/user.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  List<String> log = [];

  addLogLine(String line, {String severity='I', dynamic error, StackTrace stackTrace}){
    setState(() {
      log.add(line);
    });
    severity = severity.toLowerCase();
    Function logFunc;
    if (severity.startsWith('v'))
      logFunc = appLog.v;
    else if (severity.startsWith('d'))
      logFunc = appLog.d;
    else if (severity.startsWith('w'))
      logFunc = appLog.w;
    else if (severity.startsWith('e'))
      logFunc = appLog.e;
    else if (severity.startsWith('wtf'))
      logFunc = appLog.wtf;
    else
      logFunc = appLog.i;
    logFunc(line, error, stackTrace);
  }

  @override
  void initState() {
    void onError(ex){
      addLogLine('An unexpected error occurred. Please try again later and send'
          ' log to roisnir1@gmail.com (located at '
          '/storage/emulated/0/Android/data/com.roisnir.rooster/files/rooster.log)',
          severity: 'wtf',
          error: ex,
          stackTrace: StackTrace.current
      );
    }
    super.initState();
    try {
      loadApp().catchError(onError);
    }
    catch(ex){
      onError(ex);
    }
  }

  Future<void> loadApp() async {
    addLogLine('Initializing firebase...');
    await Firebase.initializeApp();
    addLogLine('Loading user...');
    // TODO: add authentication (maybe)
    User user;
    try {
      user = await getUser();
    }
    on SocketException catch (ex){
      addLogLine('No Connection!\r\ntry again later with better internet connection',
          severity: 'e',
          error: ex,
          stackTrace: StackTrace.current
      );
      return;
    }
    if (!user.authenticatedAsUser) {
      setState(() {
        if (user.userId == null) {
          addLogLine('No user details found');
        } else {
          addLogLine('Welcome back ${user.userId}!');
          addLogLine('Cookies has expired or not exist');
        }
        addLogLine('Redirecting to prat.idf login');
      });
      user = await Navigator.of(context).push(MaterialPageRoute(
          builder: (ctx) => Scaffold(
            body: LoginPage(user.userId),
          )));
      setState(() {
        addLogLine('${user.userId} logged in');
      });
      await user.reloadReportSettings();
    }
    addLogLine('Authenticated!');
    await user.persist();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (ctx)=> HomePage(user: user)));

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(left: 4, top: 100),
        child: Stack(
          children: <Widget>[
            Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: log.map<Widget>((line) => Text(line)).toList(),),
            Center(child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset('assets/graphics/rooster_yellow.png'),
            ))
          ],
        ),
      ),
    );
  }
}
