import 'dart:io' show Directory, File;
import 'package:log_logger/exception/debug_file_not_set_exception.dart';
import 'package:log_logger/log_logger.dart';
import 'package:log_logger/logger_level.dart';
import 'package:path/path.dart' show join;

import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

/// File path fixer.
String testPath(final String relativeFilePath) {
  return join(
    '.',
    Directory.current.path.endsWith("test") ? '' : "test",
    'test_bodies',
    relativeFilePath,
  );
}

void main() {
  test('Setting the logging level', () async {
    // The only way to test the output on the console is via a [TestProcess].
    // For coverage purposes, the same code is executed here
    final process = await TestProcess.start(
      'dart',
      [testPath(join('set_log_level.dart'))],
      runInShell: true,
    );

    final printedString = await process.stdout.next;

    expect(
      printedString,
      '[LogLogger]: The minimum logging level has been set to LoggerLevel.info.',
    );

    await process.shouldExit(0);

    LogLogger.setMinimumLogLevel(LoggerLevel.info);
  });

  test('Setting the debug mode to a value already set', () async {
    final process = await TestProcess.start(
      'dart',
      [testPath('set_again_debug_mode.dart')],
      runInShell: true,
    );

    final printedString = await process.stdout.next;

    expect(
      printedString,
      '[LogLogger]: The debug mode is already disabled.',
    );

    await process.shouldExit(0);

    LogLogger.debugMode = false;
  });

  group('Setting the debug mode on without setting correctly the debug file', () {
    test('Without setting anything', () {
      expect(() => LogLogger.debugMode = true, throwsException);
      expect(
        () => LogLogger.debugMode = true,
        throwsA(predicate((Exception e) {
          print(e);
          return e is DebugFileNotSetException;
        })),
      );
    });

    test('Setting a wrong directory or file (using the synchronous method)', () {
      expect(() => LogLogger.setDebugFileSync('', 'a'), throwsArgumentError);
      expect(() => LogLogger.setDebugFileSync('a', ''), throwsArgumentError);
      expect(() => LogLogger.debugMode = true, throwsException);
      expect(
        () => LogLogger.debugMode = true,
        throwsA(predicate((e) => e is DebugFileNotSetException)),
      );
    });
  });

  test('Setting the debug file with a wrong path', () async {
    expect(() async => await LogLogger.setDebugFile('aaa', 'test'), throwsArgumentError);
  });

  test('Setting a correct directory and file (using the asynchronous method)', () async {
    await LogLogger.setDebugFile('test/test_bodies', 'test.txt');
    final logger = LogLogger.getLogger('test');
    logger.d('Hello');
    LogLogger.debugMode = true;
    expect(LogLogger.debugMode, true);
    LogLogger.getLogger('test').i('Info message test'); // How to reuse the same instance ?
    final debugFile = File(testPath('test.txt'));
    await Future.delayed(Duration(seconds: 5));
    expect(await debugFile.exists(), true);
    final readString = await debugFile.readAsString();
    expect(
      readString.startsWith('[INFO ] [') && readString.endsWith(' -- test]:\tInfo message test\n'),
      true,
    );
    await LogLogger.clearFile();
    await debugFile.delete();
    expect(await debugFile.exists(), false);
  });

  test('Checking if debug file is empty', () async {
    await LogLogger.setDebugFile('test/test_bodies', 'test.txt');
    expect(await LogLogger.logFileIsEmpty, true);
  });

  test('Checking the path of the debug file', () async {
    await LogLogger.setDebugFile('test/test_bodies', 'test.txt');
    expect(LogLogger.debugFilePath, 'test/test_bodies/test.txt');
  });

  test('Setting the debug mode and later disabling it', () async {
    await LogLogger.setDebugFile('test/test_bodies', 'test.txt');
    final logger = LogLogger.getLogger('test');
    logger.d('Hello');
    LogLogger.debugMode = false;
    LogLogger.debugMode = true;

    final process = await TestProcess.start(
      'dart',
      [testPath('disable_debug_file.dart')],
      runInShell: true,
    );
    expect(
      await process.stdout.next,
      '[LogLogger]: The directory in which the debug log file will be saved is test/test_bodies.',
    );

    expect(
      await process.stdout.next,
      '[LogLogger]: The name of the debug log file will be test.txt.',
    );

    expect(
      await process.stdout.next,
      '[LogLogger]: The file path is correctly formed.',
    );

    expect(
      await process.stdout.next,
      '[LogLogger]: Switching 1 registered loggers to both console and file loggers.',
    );

    final temp = await process.stdout.next;

    expect(temp.startsWith('[INFO ] [') && temp.endsWith(' -- test]:\thello'), true);

    expect(
      await process.stdout.next,
      '[LogLogger]: The file path is correctly formed.',
    );

    expect(
      await process.stdout.next,
      '[LogLogger]: Switching 1 registered loggers to console only loggers.',
    );

    await process.shouldExit(0);
  });

  test('Removing loggers', () async {
    LogLogger.removeLogger('test');
    final loggerRef1 = LogLogger.getLogger('test');
    LogLogger.removeLogger('test');
    final loggerRef2 = LogLogger.getLogger('test');
    expect(loggerRef1 != loggerRef2, true);
  });

  tearDownAll(() async {
    final file = File(testPath('test.txt'));
    if (await file.exists()) {
      await file.delete();
    }
  });
}
