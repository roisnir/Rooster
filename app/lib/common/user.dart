import 'dart:convert';
import 'package:http/http.dart';
import 'package:rooster/common/utils.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:shared_preferences/shared_preferences.dart';


class User {
  String userId;
  bool authenticatedAsUser;
  bool authenticatedAsCommander;
  List<SerializableCookie> cookies;
  bool autoReport;

  User(this.userId, {
    this.authenticatedAsUser = false,
    this.authenticatedAsCommander = false,
    this.cookies,
    this.autoReport = false
  });


  static Future<User> load() async {
    final cookiesData = await storage.read(key: 'cookies');
    List<SerializableCookie> cookies;
    if (cookiesData != null)
      cookies = jsonDecode(cookiesData)
        .map<SerializableCookie>((cs)=>SerializableCookie.fromJson(cs)).toList();
    final prefs = await SharedPreferences.getInstance();
    return User(
        prefs.getString('userId'),
        cookies: cookies,
        autoReport: prefs.getBool('autoReport')
    );
  }

  setAutoReport(bool _autoReport) async {
    autoReport = _autoReport;
    await SharedPreferences.getInstance().then((value) => value.setBool('autoReport', autoReport));
  }

  setCookies(List<SerializableCookie> _cookies) async {
    cookies = _cookies;
    await storage.write(key: 'cookies', value: jsonEncode(cookies.map((c) => c.toJson()).toList()));
  }

  setUserId(String _userId) async {
    userId = _userId;
    await SharedPreferences.getInstance().then((value) => value.setString('userId', userId));
  }

  persist() async {
    await setCookies(cookies);
    await setUserId(userId);
    await setAutoReport(autoReport);
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
  if (response.headers.containsKey('set-cookie') && response.headers['set-cookie'] != null)
    user.cookies = parseSetCookie(response.headers['set-cookie']);
  final result = jsonDecode(response.body);
  user.authenticatedAsUser = result['isUserAuth'];
  user.authenticatedAsCommander = result['isCommanderAuth'];
  return user;
}
