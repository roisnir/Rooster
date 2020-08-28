import 'dart:io';
import 'package:logger/logger.dart';
// ignore: implementation_imports
import 'package:logger/src/outputs/file_output.dart';
import 'package:path_provider/path_provider.dart';


const logFileName = 'rooster.log';


AppLogger appLog = AppLogger(logFileName);


Future<String> getFilePath(fileName){
//  return getApplicationDocumentsDirectory().then((value) => null).then((dir) {
  return getExternalStorageDirectory().then((dir) => '${dir.path}/$fileName');
}


class MultipleOutputs extends LogOutput {
  final List<LogOutput> outputs;

  MultipleOutputs(this.outputs);

  @override
  void init() {
    outputs.forEach((logOutput) => logOutput.init());
  }

  @override
  void output(OutputEvent event) {
    outputs.forEach((logOutput) => logOutput.output(event));
  }

  @override
  void destroy() {
    outputs.forEach((logOutput) => logOutput.destroy());
  }
}


class LogPrinter extends PrettyPrinter {
  LogPrinter({
    methodCount = 1,
    errorMethodCount = 8,
    lineLength = 120,
    colors = true,
    printEmojis = true,
    printTime = false,
  }):super(
      methodCount: methodCount,
      errorMethodCount: errorMethodCount,
      lineLength: lineLength,
      colors: colors,
      printEmojis: printEmojis,
      printTime: printTime
  );

  @override
  List<String> log(LogEvent event) {
    var lines = super.log(event);
    return lines..add('');
  }
}


class AppLogger implements Logger {
  final String logName;
  Future<Logger> _logger;

  AppLogger(this.logName){
    _logger = getFilePath(logName).then((logPath){
      final logFile = File(logPath);
      return Logger(
        printer: LogPrinter(
          lineLength: 20,
          colors: false,
          printTime: true,
          printEmojis: false
        ),
        output: MultipleOutputs([
          ConsoleOutput(),
          FileOutput(file: logFile)
        ])
      );
    });
  }

  @override
  Future<void> close() async {
    (await _logger).close();
  }

  @override
  Future<void> d(message, [error, StackTrace stackTrace]) async {
    (await _logger).d(message, error, stackTrace);
  }

  @override
  Future<void> e(message, [error, StackTrace stackTrace]) async {
    (await _logger).e(message, error, stackTrace);
  }

  @override
  Future<void> i(message, [error, StackTrace stackTrace]) async {
    (await _logger).i(message, error, stackTrace);
  }

  @override
  Future<void> log(Level level, message, [error, StackTrace stackTrace]) async {
    (await _logger).log(level, message, error, stackTrace);
  }

  @override
  Future<void> v(message, [error, StackTrace stackTrace]) async {
    (await _logger).d(message, error, stackTrace);
  }

  @override
  Future<void> w(message, [error, StackTrace stackTrace]) async {
    (await _logger).w(message, error, stackTrace);
  }

  @override
  Future<void> wtf(message, [error, StackTrace stackTrace]) async {
    (await _logger).wtf(message, error, stackTrace);
  }
}
