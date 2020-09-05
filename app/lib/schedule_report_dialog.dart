import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:rooster/common/scheduled_report.dart';
import 'package:rooster/common/utils.dart';
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
  DateTime selectedDate = today().add(Duration(days: 1));
  bool isLoading = false;
  String validationMsg = '';

  bool validate(){
    validationMsg = '';
    if (primaryStatusCode == null || secondaryStatusCode == null) {
      validationMsg += 'status left unselected\r\n';
    }
    setState(() {validationMsg = validationMsg;});
    return validationMsg == '';
  }

  Widget get primariesDropdown => DropdownButton(
      hint: Text('select status'),
      value: primaryStatusCode,
      items: widget.statuses.values
          .map((status) => DropdownMenuItem(
                value: status.statusCode,
                child: Text(status.statusDescription),
              ))
          .toList(),
      onChanged: (v) {
        // TODO: add re-validation if error exists
        setState(() {
          primaryStatusCode = v;
          secondaryStatusCode = null;
        });
      });

  Widget get secondariesDropdown {
    List<Widget> items;
    if (primaryStatusCode != null)
      items = widget.statuses[primaryStatusCode].secondaries
          .map((status) => DropdownMenuItem(
                value: status.statusCode,
                child: Text(status.statusDescription),
              ))
          .toList();
    return DropdownButton(
      hint: Text('select secondary status'),
      value: secondaryStatusCode,
      items: items,
      onChanged: (v) {
        setState(() {
          secondaryStatusCode = v;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Schedule Report'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          OutlineButton(
            child: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
            onPressed: () {
              showDatePicker(
                      context: context,
                      initialDate: today().add(Duration(days: 1)),
                      firstDate: today().add(Duration(days: 1)),
                      lastDate: DateTime.now().add(Duration(days: 365)))
                  .then((value) => selectedDate = value);
            },
          ),
          primariesDropdown,
          secondariesDropdown,
          validationMsg == ''
            ? Container()
              : Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(color: Colors.red)),
            child: Row(
              // TODO: fix alignment
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [Icon(Icons.error_outline), Text(validationMsg,)],),
          )
          ,
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              isLoading
                  ? SizedBox(
                child: CircularProgressIndicator(),
                width: 24,
                height: 24,
              )
                  : FlatButton(
                child: Text('Add'),
                onPressed: () async {
                  if (!validate())
                    return;
                  setState(() {
                    isLoading = true;
                  });
                  final scheduledReport = ScheduledReport(selectedDate,
                      primaryStatusCode, secondaryStatusCode);
                  final formattedDate = DateFormat('yyyy-MM-dd')
                      .format(scheduledReport.date);
                  FirebaseFirestore.instance
                      .collection(
                      'users/${widget.userId}/scheduledReports')
                      .doc(formattedDate)
                      .set({
                    'date': Timestamp.fromDate(scheduledReport.date),
                    'primaryStatus': scheduledReport.primaryStatus,
                    'secondaryStatus': scheduledReport.secondaryStatus
                  })
                      .then((value) =>
                      Navigator.of(context).pop(scheduledReport))
                      .catchError((err) => throw err);
                },
              ),
              FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}
