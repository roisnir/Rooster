import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:flutter/rendering.dart';

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

  Widget buildBox(List<Widget> items) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Colors.grey[900]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: items,
      ),
    );
  }

  Widget buildGrid(
      {List<Widget> items,
      @required int crossAxisCount,
      double horizontalSpacing = 5,
      double verticalSpacing = 5}) {
    final lines = <Widget>[];
    for (var i = 0; i < items.length; i += crossAxisCount) {
      final rowItems =
          items.getRange(i, min(i + crossAxisCount, items.length)).toList();
      lines.add(Padding(
        padding: EdgeInsets.only(top: i == 0 ? 0 : verticalSpacing),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [rowItems.first] +
              rowItems
                  .skip(1)
                  .map((item) => Padding(
                        child: item,
                        padding: EdgeInsets.only(left: horizontalSpacing),
                      ))
                  .toList(),
        ),
      ));
    }
    return Column(
      children: lines,
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
              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: buildGrid(items: [
                  buildBox([
                    Text('Auto Report', style: TextStyle(fontSize: 22)),
                    Switch(
                      value: user.autoReportEnabled,
                      onChanged: updateStatus,
                    )
                  ]),
                  buildBox([
                    Text('Last Report', style: TextStyle(fontSize: 22)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 17.0, horizontal: 10),
                      child: Text(
                        user.lastReportTime?.toString() ?? 'Never Reported',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ]),
                  buildBox([
                    clearLogButton,
                    openLogButton,
                  ]),
                  buildBox([
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Image.asset('graphics/rooster_yellow.png'),
                    )
                  ])
                ], crossAxisCount: 2),
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

  Widget get clearLogButton => MaterialButton(
        child: Text('Clear Log'),
        color: Colors.yellow[700],
        onPressed: () async {
          final filePath = await getFilePath(logFileName);
          final f = File(filePath);
          f.writeAsStringSync('');
          loadLog();
        },
      );

  Widget get openLogButton => MaterialButton(
        child: Text('Open Log'),
        color: Colors.yellow[700],
        onPressed: () async {
          final filePath = await getFilePath(logFileName);
          try {
            OpenFile.open(filePath,
                type: "text/plain", uti: "public.plain-text");
          } catch (ex) {
            appLog.e('Could not open log', ex);
          }
        },
      );

  updateStatus([bool status]) async {
    if (status != null) await user.setAutoReport(status);
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }
}
