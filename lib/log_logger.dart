library log_logger;

import 'dart:io' show Directory, File;
import 'package:log_logger/logger.dart' as lib;
import 'package:path/path.dart' show join;

import 'package:log_logger/exception/debug_file_not_set_exception.dart';
import 'package:log_logger/log_filter/file_log_filter.dart';
import 'package:log_logger/log_output/synchronized_file_output.dart';
import 'package:log_logger/log_printer/console_log_printer.dart';
import 'package:log_logger/log_printer/file_log_printer.dart';
import 'package:log_logger/logger_level.dart';
import 'package:logger/logger.dart' as wrapped;

export 'package:log_logger/logger_level.dart';

/// The main class of the library.
class LogLogger {
  /// Keeps tracks of all the loggers registered and currently active since when the app was started.
  static final Map<String, lib.Logger> _registeredLoggers = {};

  /// Maps [LoggerLevel] to [Level] of the `logger` library.
  static const Map<LoggerLevel, wrapped.Level> _levels = {
    LoggerLevel.verbose: wrapped.Level.verbose,
    LoggerLevel.debug: wrapped.Level.debug,
    LoggerLevel.info: wrapped.Level.debug,
    LoggerLevel.warning: wrapped.Level.debug,
    LoggerLevel.error: wrapped.Level.debug,
    LoggerLevel.wtf: wrapped.Level.debug,
    LoggerLevel.nothing: wrapped.Level.debug,
  };

  /// Flag that is `true` if the user requested the so called `debug mode`.
  ///
  /// for more information about this fact, please do check the getter method [debugMode].
  static bool _debugMode = false;

  /// Path in which the file will be saved into.
  static String _debugFileDirectory = '';

  /// Name of the file with the logs.
  static String _debugFileName = '';

  /// Reference to the file in which logs are written.
  static late File _debugFile;

  /// Returns a new instance of a `Logger` or an already registered one in case
  /// it's already available one (and not yet deleted) with the same [label]
  static lib.Logger getLogger(final String label) {
    return _registeredLoggers.putIfAbsent(
      label,
      () => _debugMode ? _consoleAndFileLogger(label) : _consoleLogger(label),
    );
  }

  /// If a registered instance of [Logger] with label [label] is found than
  /// resources are freed and the reference is removed.
  ///
  /// Otherwise nothing gets done.
  static void removeLogger(final String label) {
    if (_registeredLoggers.containsKey(label) &&
        _registeredLoggers[label] != null) {
      _registeredLoggers[label]!.close();
      _registeredLoggers.remove(label);
    }
  }

  /// Sets the path where the debug file will be saved into.
  ///
  /// Throws an [ArgumentError] is [path] is empty or if it is not existent.
  static Future<void> _setDebugFileDirectory(final String path) async {
    if (path.isEmpty) {
      throw ArgumentError("The path of the file cannot be empty.");
    }
    if (await Directory(path).exists()) {
      print(
        '[LogLogger]: The directory in which the debug log file will be saved is $path.',
      );
      _debugFileDirectory = path;
    } else {
      throw ArgumentError.value(
        path,
        'path',
        'It is not a valid path (it does not exist)',
      );
    }
  }

  /// Sets the path where the debug file will be saved into.
  /// The path is not checked for safety hence the method can be synchronous.
  /// Use it at your own risk.
  ///
  /// Throws an [ArgumentError] is [path] is empty.
  static void _setDebugFileDirectorySync(final String path) {
    if (path.isEmpty) {
      throw ArgumentError("The path of the file cannot be empty.");
    }
    print(
      '[LogLogger]: The directory in which the debug log file will be saved is $path.',
    );
    _debugFileDirectory = path;
  }

  /// Sets the name of the file in which the logs will be saved into.
  ///
  /// **ATTENTION**: Invoke this method only after invoking [debugFileDirectory].
  ///
  /// Throws an [ArgumentError] is [debugFileName] is empty.
  static void _setDebugFileName(final String debugFileName) {
    if (debugFileName.isEmpty) {
      throw ArgumentError("The name of the file cannot be empty.");
    }
    print(
      '[LogLogger]: The name of the debug log file will be $debugFileName.',
    );
    _debugFileName = debugFileName;
    _debugFile = File('$_debugFileDirectory/$_debugFileName');
  }

  /// Sets the debug file to be in the path [path] with file name [fileName].
  /// Invokes [setDebugFileDirectory] and [setDebugFileName] in sequence.
  ///
  /// Throws an [ArgumentError] is [path] or [debugFileName] are empty or
  /// if [path] is not existent.
  static Future<void> setDebugFile(
    final String path,
    final String fileName,
  ) async {
    await _setDebugFileDirectory(path);
    _setDebugFileName(fileName);
  }

  /// Sets the debug file to be in the path [path] with file name [fileName].
  /// Invokes [setDebugFileDirectorySync] and [setDebugFileName] in sequence.
  ///
  /// Throws an [ArgumentError] is [path] or [debugFileName] are empty.
  static void setDebugFileSync(final String path, final String fileName) {
    _setDebugFileDirectorySync(path);
    _setDebugFileName(fileName);
  }

  /// Returns `true` if the debug mode is active, `false` otherwise.
  static bool get debugMode => _debugMode;

  /// Returns `true` if the path in which to save the file is not empty and if the
  /// file name is not empty.
  ///
  /// Returns `false` otherwise.
  static bool get _filePathIsCorrect =>
      _debugFileDirectory.isNotEmpty &&
      _debugFileName.isNotEmpty &&
      _debugFile.path.contains(_debugFileDirectory) &&
      _debugFile.path.contains(_debugFileName);

  /// Returns the debug file path or where it should be if the debug mode is disabled.
  static String get debugFilePath => _debugFile.path;

  /// Sets the debug mode (`true` for activating it, `false` for disabling it).
  /// If [newMode] corresponds to the current state of the debug mode then nothing is done.
  ///
  /// If [debugFileDirectory] and [debugFileName] were not called prior to this method
  /// the debug mode does not get set.
  static set debugMode(final bool newMode) {
    if (_debugMode == newMode) {
      print(
        '[LogLogger]: The debug mode is already ${newMode ? 'enabled' : 'disabled'}.',
      );
      return;
    }

    print(
      '[LogLogger]: The file path is ${_filePathIsCorrect ? "" : "not "}correctly formed.',
    );

    if (newMode && !_filePathIsCorrect) {
      throw DebugFileNotSetException(
        'The debug mode was requested but the path provided (path = \'${join(_debugFileDirectory, _debugFileName)}\') was not valid.',
      );
    }

    _debugMode = newMode;

    if (_debugMode) {
      print(
        "[LogLogger]: Switching ${_registeredLoggers.keys.length} registered loggers to both console and file loggers.",
      );
      for (final label in _registeredLoggers.keys) {
        _registeredLoggers[label]!.close();
        _registeredLoggers.update(label, (_) => _consoleAndFileLogger(label));
      }
    } else {
      print(
        "[LogLogger]: Switching ${_registeredLoggers.keys.length} registered loggers to console only loggers.",
      );
      for (final className in _registeredLoggers.keys) {
        _registeredLoggers[className]!.close();
        _registeredLoggers.update(className, (_) => _consoleLogger(className));
      }
    }
  }

  /// Erases the content of the log file.
  static Future<void> clearFile() async {
    await _debugFile.writeAsString("");
    print(
      "[LogLogger]: The log file $_debugFileName was cleared and it is now empty.",
    );
  }

  /// Returns `true` if the debug file is empty, `false` otherwise.
  static Future<bool> get logFileIsEmpty async {
    final exists = await _debugFile.exists();
    final content = exists ? (await _debugFile.readAsString()) : "";

    print(
      "[LogLogger]: The log file is ${content.isNotEmpty ? 'not ' : ''}empty.",
    );
    return content.isEmpty;
  }

  /// Returns an instance of `Logger` for console debugging.
  static lib.Logger _consoleLogger(final String className) {
    return lib.Logger(
      wrapped.Logger(
        printer: ConsoleLogPrinter(className),
      ),
    );
  }

  /// Returns an instance of `Logger` for console and file debugging.
  static lib.Logger _consoleAndFileLogger(final String className) {
    return lib.Logger(
      wrapped.Logger(
        printer: FileLogPrinter(className),
        output: wrapped.MultiOutput([
          wrapped.ConsoleOutput(),
          SynchronizedFileOutput(_debugFile),
        ]),
        filter: FileLogFilter(),
        level: wrapped.Level.verbose,
      ),
    );
  }

  /// Sets the minimum logging level: messages with logging level below that
  /// will be printed neither in the console nor in the file.
  static void setMinimumLogLevel(final LoggerLevel level) {
    wrapped.Logger.level = _levels[level]!;
    print("[LogLogger]: The minimum logging level has been set to $level.");
  }
}
