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

  addLogLine(String line){
    log.add(line);
    appLog.i(line);
  }

  @override
  void initState() {
    super.initState();
    addLogLine('Loading user...');
    getUser().then((user) async {
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
                  body: LoginPage(),
                )));
        setState(() {
          addLogLine('${user.userId} logged in');
        });
      }
      addLogLine('Authenticated!');
      await user.persist();
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (ctx)=> HomePage(user: user)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(left: 4, top: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: log.map<Widget>((line) => Text(line)).toList(),
        ),
      ),
    );
  }
}
