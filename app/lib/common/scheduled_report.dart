class ScheduledReport {
  final DateTime date;
  final String primaryStatus;
  final String secondaryStatus;

  ScheduledReport(this.date, this.primaryStatus, this.secondaryStatus);

  ScheduledReport.fromDoc(
      Map<String, dynamic> doc
      ) : this(doc['date'], doc['primaryStatus'], doc['secondaryStatus']);
}