import 'dart:convert';
import 'package:flutter/cupertino.dart';

Map<String, Status> parseStatuses(String statusListJson){
  return Map.fromIterable(
      jsonDecode(statusListJson),
      key: (item) => item['statusCode'],
      value: (item) => Status.fromJson(item)
  );
}

class Status {
  final String statusCode;
  final String statusDescription;
  final List<Status> secondaries;

  Status({
    @required this.statusCode,
    @required this.statusDescription,
    @required this.secondaries});

  Status.fromJson(Map<String, dynamic> json) : this(
      statusCode: json['statusCode'],
      statusDescription: json['statusDescription'],
      secondaries: json.containsKey('secondaries')
          ? json['secondaries'].map<Status>((subJson) => Status.fromJson(json)).toList() : []
  );
}
