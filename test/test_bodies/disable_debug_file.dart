import 'dart:io';
import 'package:path/path.dart' show join;

import 'package:log_logger/log_logger.dart';

/// File path fixer.
String testPath(final String relativeFilePath) {
  return join(
    '.',
    Directory.current.path.endsWith("test") ? '' : "test",
    'test_bodies',
    relativeFilePath,
  );
}

/// This is the test body but not a test itself since the library `test_process`
/// is used.
void main() async {
  await LogLogger.setDebugFile('test/test_bodies', 'test.txt');
  final logger = LogLogger.getLogger('test');
  logger.i('hello');
  LogLogger.debugMode = true;
  LogLogger.getLogger('test').i('hello');
  LogLogger.debugMode = false;
  await Future.delayed(Duration(seconds: 5));
  final file = File(testPath('test.txt'));

  await file.delete();
}
