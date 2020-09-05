import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:rooster/common/scheduled_report.dart';
import 'common/status.dart';

class ReportScheduleDialog extends StatefulWidget {
  final Map<String, Status> statuses;
  final String userId;

  ReportScheduleDialog({@required this.statuses, @required this.userId});

  @override
  _ReportScheduleDialogState createState() => _ReportScheduleDialogState();
}

class _ReportScheduleDialogState extends State<ReportScheduleDialog> {
  String primaryStatusCode;
  String secondaryStatusCode;
  DateTime selectedDate;
  bool isLoading = false;

  Widget get primariesDropdown =>
      DropdownButton(items: widget.statuses.values.map((status) =>
        DropdownMenuItem(
          value: status.statusCode,
          child: Text(status.statusDescription),)).toList(),
      onChanged: (v){
        setState(() {
          primaryStatusCode = v;
        });
      });

  Widget get secondariesDropdown {
    List<Widget> items;
    if (primaryStatusCode != null)
      items = widget.statuses[primaryStatusCode].secondaries.map((status) =>
          DropdownMenuItem(
            value: status.statusCode,
            child: Text(status.statusDescription),
          )).toList();
    return DropdownButton(items: items, onChanged: (v){
      setState(() {
        secondaryStatusCode = v;
      });
    },);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Schedule Report'),
      content: Column(children: [
        OutlineButton(
          child: Text(DateTime.now().toString()),
          onPressed: () {
            showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(Duration(days: 365))).then(
                    (value) => selectedDate = value);
            },
        ),
        primariesDropdown,
        secondariesDropdown,
        isLoading
            ? SizedBox(child: CircularProgressIndicator(), width: 24, height: 24,)
            : ButtonBar(children: [
          FlatButton(
            child: Text('Add'),
            onPressed: () async {
              setState(() {
                isLoading = true;
              });
              final scheduledReport = ScheduledReport(selectedDate, primaryStatusCode, secondaryStatusCode);
              final formattedDate = DateFormat('yyyy-MM-dd').format(scheduledReport.date);
              FirebaseFirestore.instance
                  .collection('users/${widget.userId}/scheduledReports')
                  .doc(formattedDate).set({
                'date': Timestamp.fromDate(scheduledReport.date),
                'primaryStatus': scheduledReport.primaryStatus,
                'secondaryStatus': scheduledReport.secondaryStatus
              }).then((value) => Navigator.of(context).pop(scheduledReport)).catchError((err) => throw err);
            },
          ),
          FlatButton(
            child: Text('Cancel'),
            onPressed: (){
              Navigator.of(context).pop();
            },)],)
      ],),
    );
  }
}
