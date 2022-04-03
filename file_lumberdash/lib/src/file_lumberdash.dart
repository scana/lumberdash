import 'dart:io';

import 'package:lumberdash/lumberdash.dart';
import 'package:synchronized/synchronized.dart';

/// [LumberdashClient] that writes your logs to the given file path
/// in the file system
class FileLumberdash extends LumberdashClient {
  File _logFile;
  static final _lock = Lock();

  FileLumberdash({
    required String filePath,
  }) : _logFile = File(filePath);

  /// Records a regular message
  @override
  void logMessage(String message, [Map<String, String>? extras]) {
    if (extras != null) {
      _log('[M] $message, extras: $extras');
    } else {
      _log('[M] $message');
    }
  }

  /// Records a warning message
  @override
  void logWarning(String message, [Map<String, String>? extras]) {
    if (extras != null) {
      _log('[W] $message, extras: $extras');
    } else {
      _log('[W] $message');
    }
  }

  /// Records a fatal message
  @override
  void logFatal(String message, [Map<String, String>? extras]) {
    if (extras != null) {
      _log('[F] $message, extras: $extras');
    } else {
      _log('[F] $message');
    }
  }

  /// Records an error message
  @override
  Future<void> logError(exception, [dynamic stacktrace]) async {
    if (stacktrace != null) {
      _log('[E] { exception: $exception, stacktrace: $stacktrace }');
    } else {
      _log('[E] { exception: $exception }');
    }
  }

  Future<void> _log(String data) async {
    try {
      _lock.synchronized(() async {
        final date = DateTime.now();
        await _logFile.writeAsString(
          '${date.toIso8601String()}+${timeZoneOffset(date)} - $data\n',
          mode: FileMode.writeOnlyAppend,
          flush: true,
        );
      });
    } catch (e) {
      print("Lumberdash exception: $e");
    }
  }
  
  String timeZoneOffset(DateTime dateTime) {
    final offsetMinutes = dateTime.timeZoneOffset.inMinutes;
    final hours = offsetMinutes ~/ 60;
    final minutes = offsetMinutes % 60;
    return "$hours:${minutes == 0 ? "00" : minutes}";
  }
}
