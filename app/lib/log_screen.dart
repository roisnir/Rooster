import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'common/log.dart';
import 'package:flutter/material.dart';
import 'package:rooster/common/log.dart';
import 'package:open_file/open_file.dart';

class LogScreen extends StatefulWidget {
  @override
  _LogScreenState createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  String logText = '';
  Timer logUpdater;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Actions:',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
              ),
              ButtonBar(
                alignment: MainAxisAlignment.start,
                children: [
                  clearLogButton,
                  openLogButton
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Log:',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
              ),
              Expanded(
                  child: Container(
                    color: Colors.grey[900],
                    child: SingleChildScrollView(
                      reverse: true,
                      child: RichText(
                        text: TextSpan(text: logText),
                      ),
                    ),
                  ))
            ]),
      ),
    );
  }
  Widget buildCircleButton({@required String text, @required Widget icon, @required Function onTap})=>InkWell(
    onTap: onTap,
    child: Column(
        children: [CircleAvatar(
          backgroundColor: Colors.yellow[600],
          child: icon,
//      borderSide: BorderSide(color: Colors.yellow[700]),
        ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(text),
          )
        ]
    ),
  );

  Widget get clearLogButton => buildCircleButton(
    text: 'Clear Log',
    icon: Icon(Icons.clear),
    onTap: () async {
        final filePath = await getFilePath(logFileName);
        final f = File(filePath);
        f.writeAsStringSync('');
        loadLog();
      },
  );

  Widget get openLogButton => buildCircleButton(
    text: 'Open Log',
    icon: Icon(Icons.open_in_new),
//    borderSide: BorderSide(color: Colors.yellow[700]),
    onTap: () async {
      final filePath = await getFilePath(logFileName);
      try {
        OpenFile.open(filePath,
            type: "text/plain", uti: "public.plain-text");
      } catch (ex) {
        appLog.e('Could not open log', ex);
      }
    },
  );

  @override
  void dispose() {
    logUpdater.cancel();
    super.dispose();
  }
}
