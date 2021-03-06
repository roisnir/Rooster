import 'dart:io';
import 'dart:math';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


const storage = FlutterSecureStorage();
const baseUrl = 'https://one.prat.idf.il';

List<SerializableCookie> parseSetCookie(String setCookie){
  final sep = RegExp(r"(,)[^\s_]");
  final cookies = <SerializableCookie>[];
  String tmp;
  for (var i = setCookie.indexOf(sep); i >= 0;i = setCookie.indexOf(sep)){
    tmp = setCookie.substring(0, i);
    print(tmp);
    cookies.add(SerializableCookie(Cookie.fromSetCookieValue(tmp)));
    setCookie = setCookie.substring(i + 1);
  }
  cookies.add(SerializableCookie(Cookie.fromSetCookieValue(setCookie)));
  return cookies;
}

DateTime today(){
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

String ellipsis(dynamic obj, {maxLength=10}){
  final str = obj.toString();
  return str.substring(0, min(str.length, maxLength)) +
      (str.length > maxLength ? '...' : '');
}
