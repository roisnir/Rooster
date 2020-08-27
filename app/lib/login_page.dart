import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:rooster/common/user.dart';
import 'package:rooster/common/utils.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_json_widget/flutter_json_widget.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  WebViewController controller;
  final cookieManager = WebviewCookieManager();
  Timer cookieChecker;
  Map<String, SerializableCookie> cookies = {};
  String userId = '';

  @override
  void initState() {
    super.initState();
    cookieManager.clearCookies();
    cookieChecker = Timer.periodic(Duration(seconds: 1), (timer) {
      scrapeData();
      if (cookies.containsKey('AppCookie'))
        returnUser();
    });
  }

  returnUser() {
    Navigator.of(context).pop(User(userId, authenticatedAsUser: true, cookies: cookies.values.toList()));
  }

  scrapeData() async {
    final gotCookies = await cookieManager.getCookies(baseUrl);
    for (var item in gotCookies) {
      cookies[item.name] = SerializableCookie(item);
    }
    String result;
    try {
      result = await controller.evaluateJavascript(
          "try {document.getElementsByName('tz')[0].value} catch (error){null}");
    }
    catch (ex){
    }
    if (result != null && RegExp(r'^"?[0-9]+"?$').hasMatch(result)) {
      setState(() {
        userId = result.replaceAll('"', '');
      });
    }
  }

  @override
  void dispose() {
    cookieChecker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        WebView(
          initialUrl: baseUrl,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (ctrl)=>controller=ctrl,
        ),
        DraggableScrollableSheet(
          initialChildSize: 0.15,
          minChildSize: 0.1,
        builder: (ctx, ctl)=>SingleChildScrollView(
          controller: ctl,
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10),),
              child: SafeArea(
                top: false,
                maintainBottomViewPadding: true,
                minimum: EdgeInsets.only(bottom: MediaQuery.of(context).size.height),
                child: Column(
                  children: [
                    Icon(Icons.drag_handle, size: 20, color: Theme.of(context).canvasColor,),
                    JsonViewerWidget({
                      'UserId': userId,
                      'Cookies': serializeCookies()
                    })],
                ),
              ))
        ),
      ),

      ],
    );
  }

  Map<String, String> serializeCookies(){
    return Map.fromEntries(cookies.entries.map((e) => MapEntry(e.key, e.value.toString())));
  }
}
