import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduledReport {
  final DateTime date;
  final String primaryStatus;
  final String secondaryStatus;

  ScheduledReport(this.date, this.primaryStatus, this.secondaryStatus);

  ScheduledReport.fromDoc(
      Map<String, dynamic> doc
      ) : this(doc['date'].toDate(), doc['primaryStatus'], doc['secondaryStatus']);
}