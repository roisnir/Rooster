import 'package:logger/logger.dart';

class AppLogPrinter extends PrettyPrinter {
  AppLogPrinter({
    methodCount = 3,
    errorMethodCount = 8,
    lineLength = 120,
    colors = true,
    printEmojis = true,
    printLevelStrings = true,
    printTime = false,
  }):super(
      methodCount: methodCount + 2,
      errorMethodCount: errorMethodCount,
      lineLength: lineLength,
      colors: colors,
      printEmojis: printEmojis,
      printLevelStrings: printLevelStrings,
      printTime: printTime
  );




  @override
  String formatStackTrace(StackTrace stackTrace, int methodCount) {
    final lines = super.formatStackTrace(stackTrace, methodCount).split('\n');
    return lines.sublist(2).join('\n');
  }

  @override
  String getTime() {
    return DateTime.now().toString();
  }

  @override
  List<String> log(LogEvent event) {
    return super.log(event)..add('');
  }
}
