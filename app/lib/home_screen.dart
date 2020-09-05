import 'package:rooster/dashboard.dart';
import 'package:rooster/log_screen.dart';
import 'package:flutter/material.dart';
import 'package:rooster/common/user.dart';

class HomePage extends StatefulWidget {
  final User user;

  HomePage({Key key, @required this.user}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int curScreenIndex = 0;
  List<Widget> screens;

  @override
  void initState() {
    super.initState();
    screens = [
      Dashboard(user: widget.user,),
      LogScreen()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Image.asset('assets.graphics/rooster_yellow.png'),
            ),
            ListTile(title: Text('Home'), onTap: (){
              setState(() {
                curScreenIndex = 0;
              });
              Navigator.of(context).pop();
            }),
            ListTile(title: Text('Log'), onTap: (){
              setState(() {
                curScreenIndex = 1;
              });
              Navigator.of(context).pop();
            },),
          ],
        ),
      ),
      body: screens[curScreenIndex],
    );
  }
}
