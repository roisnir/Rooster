import 'dart:io';
import 'dart:async';
import 'common/log.dart';
import 'package:flutter/material.dart';
import 'package:rooster/common/log.dart';
import 'package:rooster/common/user.dart';
import 'package:open_file/open_file.dart';


class HomePage extends StatefulWidget {
  final User user;
  HomePage({Key key, @required this.user}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User user;
  String logText = '';
  Timer logUpdater;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    loadLog();
    logUpdater = Timer.periodic(Duration(seconds: 3), (timer) => loadLog());
  }

  loadLog() async {
    final logPath = await getFilePath(logFileName);
    final text = await File(logPath).readAsString();
    setState(() {
      logText = text;
    });
  }

  Widget buildBox(List<Widget> items){
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey[900]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: items,),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(padding: EdgeInsets.only(top: 100),),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildBox([
                    Text('Auto Report', style: TextStyle(fontSize: 22)),
                    Switch(value: user.autoReportEnabled, onChanged: updateStatus,)
                  ]),
                  buildBox([
                    Text('Last Report', style: TextStyle(fontSize: 22)),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 17.0),
                      child: Text(user.lastReportTime?.toString() ?? 'Never Reported'),
                    )
                  ]),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                  MaterialButton(child: Text('Clear Log'), color: Colors.yellow[700], onPressed: () async {
                    final filePath = await getFilePath(logFileName);
                    final f = File(filePath);
                    f.writeAsStringSync('');
                  },),
                  MaterialButton(child: Text('Open Log'), color: Colors.yellow[700], onPressed: () async {
                    final filePath = await getFilePath(logFileName);
                    try {
                      OpenFile.open(
                          filePath, type: "text/plain",
                          uti: "public.plain-text");
                    }
                    catch (ex) {
                      appLog.e('Could not open log', ex);
                    }
                  },),
                ].map((wgt) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: wgt,
                  )).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(alignment: Alignment.centerLeft, child: Text('Log:', style: Theme.of(context).textTheme.subtitle1,),),
              ),
              Expanded(child: Container(
                    color: Colors.grey[900],
                child: SingleChildScrollView(
                  reverse: true,
                  child: RichText(
                  text: TextSpan(text: logText),
                ),),
              ))

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
  @override
  void dispose() {

    super.dispose();
  }
}
