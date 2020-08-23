import 'dart:io';
import 'package:rooster/common/log.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


const storage = FlutterSecureStorage();
const baseUrl = 'https://one.prat.idf.il';

configureScheduledTask(Function(String taskId) callback) async {
  await BackgroundFetch.configure(
      BackgroundFetchConfig(
          minimumFetchInterval: 15,
          stopOnTerminate: false,
          startOnBoot: true,
          enableHeadless: true,
          requiresBatteryNotLow: false,
          requiredNetworkType: NetworkType.ANY,
          requiresCharging: false,
          requiresStorageNotLow: false,
          requiresDeviceIdle: false), (String taskId) async {
        try {
          callback(taskId);
        }
        catch (ex) {
          appLog.e('Failed executing task', ex);
        }
        finally {
          BackgroundFetch.finish(taskId);
        }
  }).then((int status) {
    appLog.i('[BackgroundFetch] configure success: $status');
  }).catchError((e) {
    appLog.i('[BackgroundFetch] configure ERROR: $e');
  });
}


List<SerializableCookie> parseSetCookie(String setCookie){
  final sep = RegExp(r"(,)\S");
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