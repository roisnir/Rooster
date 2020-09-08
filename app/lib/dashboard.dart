import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:rooster/common/log.dart';
import 'package:rooster/common/scheduled_report.dart';
import 'package:rooster/common/user.dart';
import 'package:rooster/common/utils.dart';
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
  Future<List<ScheduledReport>> scheduled;
  Future<Map<String, Status>> _statuses;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    scheduled = loadScheduled();
    _statuses = rootBundle.loadStructuredData(
        'assets/strings/statuses.json',
            (jsonStr) async => parseStatuses(jsonStr));
  }

  Future<List<ScheduledReport>> loadScheduled() {
    return FirebaseFirestore.instance
      .collection('users/${widget.user.userId}/scheduledReports')
      .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(today()))
      .get()
      .then((queryRes) =>
      queryRes.docs
          .map<ScheduledReport>((doc) => ScheduledReport.fromDoc(doc.data())))
      .then((value) => value.toList());
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
                        Text('Auto Report is ${user.autoReportEnabled
                            ? 'enabled'
                            : 'disabled'}', style: Theme
                            .of(context)
                            .textTheme
                            .bodyText2),
                        Switch(
                          value: user.autoReportEnabled,
                          onChanged: updateStatus,
                        )
                      ]),
                    ),
                    Expanded(
                      flex: 1,
                      child: buildBox([
                        Text('Last reported at', style: Theme
                            .of(context)
                            .textTheme
                            .bodyText2),
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            user.lastReportTime?.toString() ?? 'Never Reported',
                            style: Theme
                                .of(context)
                                .textTheme
                                .headline6,
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
                      style: Theme
                          .of(context)
                          .textTheme
                          .subtitle1,
                    ),
                    addReportButton
                  ],
                ),
              ),
              Expanded(
                  child: Container(
                    color: Colors.grey[900],
                    child: FutureBuilder<List<dynamic>>(
                      future: Future.wait([scheduled, _statuses]),
                      builder: (ctx, snapshot) {
                        if (snapshot.hasError) {
                          appLog.e('error', snapshot.error, (snapshot.error as Error)?.stackTrace);
                          return Center(child: Icon(Icons.error_outline));
                        }
                        if (!snapshot.hasData)
                          return Center(child: CircularProgressIndicator(),);
                        List<ScheduledReport> _scheduled = snapshot.data[0];
                        Map<String, Status> statuses = snapshot.data[1];
                        return ListView.separated(
                            itemBuilder: (ctx, i) {
                              final report = _scheduled[i];
                              return ListTile(
                                title: Row(
                                  children: [
                                    Text('${DateFormat('dd/MM/yy').format(report.date)}  -  ${statuses[report.primaryStatus]}'),
                                  ],
                                ),
//                                isThreeLine: true,
                                trailing: IconButton(icon: Icon(Icons.delete), onPressed: () async {
                                  final bool res = await showDialog(context: context, child: SimpleDialog(
                                    title: Text('Are You Sure?'),
                                    children: [ButtonBar(
                                      alignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        FlatButton(child: Text('No'), onPressed: (){Navigator.of(context).pop(false);},),
                                        FlatButton(child: Text('Yes'), onPressed: (){Navigator.of(context).pop(true);})
                                    ],)],
                                  ));
                                  if (!(res ?? false))
                                    return;
                                  final formattedDate = DateFormat('yyyy-MM-dd')
                                      .format(report.date);
                                  FirebaseFirestore.instance
                                      .collection(
                                      'users/${widget.user.userId}/scheduledReports')
                                      .doc(formattedDate).delete().then((value) {
                                        scheduled = loadScheduled();
                                        setState((){});
                                      });
                                },),
                                subtitle: Text('${statuses[report.primaryStatus].secondaries.singleWhere((s) => s.statusCode == report.secondaryStatus)}'),
                              );
                            },
                            separatorBuilder: (ctx, i) => Divider(),
                            itemCount: _scheduled.length);
                      },
                    ),
                  ))
            ]),
      ),
    );
  }

  Widget get addReportButton {
    return IconButton(icon: Icon(Icons.add), onPressed: () async {
      final statuses = await _statuses;
      ScheduledReport res = await showDialog(
          context: context,
          builder: (ctx) =>
              ReportScheduleDialog(
                statuses: statuses,
                userId: user.userId,))
          .catchError((err) {
        showDialog(
            context: context,
            child: AlertDialog(
              title: Text('Error!'),
              content: Center(child: Column(
                children: [
                  Icon(Icons.error_outline),
                  Text('An error occurred, please try again later.'),
                  RaisedButton(child: Text('OK'), onPressed: () {
                    Navigator.of(context).pop();
                  },)
                ],
              ),),
            ));
      });
      if (res != null) {
        final _scheduled = await scheduled;
        setState(() {
          _scheduled.add(res);
        });
      }
    },);
  }

  updateStatus([bool status]) async {
    if (status != null) await user.setAutoReport(status);
    setState(() {});
  }
}
