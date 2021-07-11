import 'package:logger/logger.dart' as lib;

class Logger {
  final lib.Logger _logger;

  const Logger(this._logger);

  /// Logs a message at level [LoggerLevel.verbose].
  void v(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.v(message, error, stackTrace);
  }

  /// Logs a message at level [LoggerLevel.debug].
  void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error, stackTrace);
  }

  /// Logs a message at level [LoggerLevel.info].
  void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error, stackTrace);
  }

  /// Logs a message at level [LoggerLevel.warning].
  void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error, stackTrace);
  }

  /// Logs a message at level [LoggerLevel.error].
  void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error, stackTrace);
  }

  /// Logs a message at level [LoggerLevel.wtf].
  void wtf(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.wtf(message, error, stackTrace);
  }

  /// Closes the logger and releases all resources.
  void close() {
    _logger.close();
  }
}
