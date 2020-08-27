import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:workmanager/workmanager.dart';
import 'common/log.dart';
import 'loading_screen.dart';
import 'package:flutter/material.dart';

void writeLog(){
  Workmanager.executeTask((taskName, inputData) async {
    print('taskName:');
    print(taskName);
    print('inputData:');
    print(inputData);
    await appLog.i('reported at ${DateTime.now()}');
    return Future.value(true);
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager.initialize(writeLog, isInDebugMode: true);
//  Workmanager.registerPeriodicTask('RoosterTask_${Uuid().v4()}', 'RoosterTask',
//      tag: 'RoosterTask',
//      constraints: Constraints(
//          networkType: NetworkType.connected,
//          requiresBatteryNotLow: false,
//          requiresCharging: false,
//          requiresDeviceIdle: false,
//          requiresStorageNotLow: false
//      ));
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        brightness: Brightness.dark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoadingScreen(),
    );
  }
}
