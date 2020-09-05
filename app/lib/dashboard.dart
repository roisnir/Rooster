import 'dart:convert';

import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rooster/common/scheduledReport.dart';
import 'package:rooster/common/user.dart';
import 'package:rooster/schedule_report_dialog.dart';

import 'common/status.dart';

class Dashboard extends StatefulWidget {
  final User user;

  Dashboard({Key key, @required this.user}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  User user;
  List<ScheduledReport> scheduled;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  Widget buildBox(List<Widget> items) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      padding: EdgeInsets.all(8),
      constraints: BoxConstraints.expand(
        height: 100
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5), color: Colors.grey[900]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: items,
      ),
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
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 1,
                      child: buildBox([
                        Text('Auto Report is ${user.autoReportEnabled ? 'enabled' : 'disabled'}', style: Theme.of(context).textTheme.bodyText2),
                        Switch(
                          value: user.autoReportEnabled,
                          onChanged: updateStatus,
                        )
                      ]),
                    ),
                    Expanded(
                      flex: 1,
                      child: buildBox([
                        Text('Last reported at', style: Theme.of(context).textTheme.bodyText2),
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            user.lastReportTime?.toString() ?? 'Never Reported',
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ),
                      ]),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                      Text(
                      'Scheduled reports',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    IconButton(icon: Icon(Icons.add), onPressed: () async {
                      final statuses = await rootBundle.loadStructuredData(
                          'assets/strings/statuses.json',
                          (jsonStr) async => parseStatuses(jsonStr));
                      ScheduledReport res = await showDialog(
                          context: context,
                          builder: (ctx) =>
                              ReportScheduleDialog(
                                statuses: statuses,
                                userId: user.userId,))
                          .catchError((err){
                            showDialog(
                                context: context,
                                child: AlertDialog(
                                  title: Text('Error!'),
                                  content: Center(child: Column(
                                    children: [
                                      Icon(Icons.error_outline),
                                      Text('An error occurred, please try again later.'),
                                      RaisedButton(child: Text('OK'), onPressed: (){Navigator.of(context).pop()},)
                                    ],
                                  ),),
                                ));
                      });
                      if (res != null){

                      }
                    },)
                  ],
                ),
              ),
              Expanded(
                  child: Container(
                    color: Colors.grey[900],
                    child: ListView.separated(
                        itemBuilder: (ctx, i)=> ListTile(title: Text(i.toString()),),
                        separatorBuilder: (ctx, i) => Divider(),
                        itemCount: 3),
                  ))
            ]),
      ),
    );
  }

  updateStatus([bool status]) async {
    if (status != null) await user.setAutoReport(status);
    setState(() {});
  }
}
