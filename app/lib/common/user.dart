import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart';
import 'package:rooster/common/log.dart';
import 'package:rooster/common/utils.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:shared_preferences/shared_preferences.dart';


class User {
  String userId;
  bool authenticatedAsUser;
  bool authenticatedAsCommander;
  List<SerializableCookie> cookies;
  bool autoReportEnabled;
  DateTime lastReportTime;
  DocumentReference _ref;

  User({
    this.userId,
    this.authenticatedAsUser = false,
    this.authenticatedAsCommander = false,
    this.cookies,
    this.autoReportEnabled = false,
    this.lastReportTime
  }){
    cookies ??= [];
    _ref = FirebaseFirestore.instance.doc('users/$userId');
  }


  static Future<User> load() async {
    final userId = await SharedPreferences.getInstance().then((prefs) => prefs.getString('userId'));
    if (userId == null)
      return User();
    final user = (await FirebaseFirestore.instance.doc('users/$userId').get()).data();
    List<SerializableCookie> cookies;
    if (user.containsKey('cookies'))
      cookies = user['cookies'].map<SerializableCookie>((cs)=>SerializableCookie.fromJson(cs)).toList();
    return User(
        userId: userId,
        cookies: cookies,
        autoReportEnabled: user['autoReportEnabled'],
        lastReportTime: user.containsKey('lastReportedAt') ? user['lastReportedAt']?.toDate() : null
    );
  }

  setAutoReport(bool _autoReport) async {
    autoReportEnabled = _autoReport;
    await _ref.set({'autoReportEnabled': autoReportEnabled}, SetOptions(merge: true));
  }

  setCookies(List<SerializableCookie> _cookies) async {
    cookies = _cookies;
    await _ref.set({'cookies': cookies.map((c) => c.toJson()).toList()}, SetOptions(merge: true));
  }

  setUserId(String _userId) async {
    userId = _userId;
    await SharedPreferences.getInstance().then((value) => value.setString('userId', userId));
  }

  persist() async {
    await setUserId(userId);
    await _ref.set({
      'autoReportEnabled': autoReportEnabled,
      'cookies': cookies.map((c) => c.toJson()).toList(),
    },
        SetOptions(merge: true));
  }
}

Future<User> getUser() async {
  final user = await User.load();
  print(user.cookies);
  print(user.userId);
  final req = Request('GET', Uri.parse('https://one.prat.idf.il/api/account/getUser'));
  if (user.cookies != null) {
    req.headers['Cookie'] =
        user.cookies.map((c) => '${c.cookie.name}=${c.cookie.value}').join(';');
    print('Sending Request with cookie: ' + req.headers['Cookie']);
  }
  final response = await Response.fromStream(await req.send());
  if (response.headers.containsKey('set-cookie') && response.headers['set-cookie'] != null) {
    if (user.cookies.any((element) => element.cookie.name == 'AppCookie') && !response.headers['set-cookie'].contains('AppCookie'))
      appLog.w("User has AppCookie but set-cookie doesn't. ignoring new cookies");
    else
      user.cookies = parseSetCookie(response.headers['set-cookie']);
  }
  final result = jsonDecode(response.body);
  user.authenticatedAsUser = result['isUserAuth'];
  user.authenticatedAsCommander = result['isCommanderAuth'];
  return user;
}
