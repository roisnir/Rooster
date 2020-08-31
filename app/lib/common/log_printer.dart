import 'package:logger/logger.dart';

class AppLogPrinter extends PrettyPrinter {
  AppLogPrinter({
    methodCount = 1,
    errorMethodCount = 8,
    lineLength = 120,
    colors = true,
    printEmojis = true,
    printLevelStrings = true,
    printTime = false,
  }):super(
      methodCount: methodCount + 1,
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
    if (lines.last.contains('LogPrinter.log'))
      lines.removeAt(lines.length-1);
    return lines.join('\n');
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
