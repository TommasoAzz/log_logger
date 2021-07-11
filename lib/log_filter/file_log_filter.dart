import 'package:logger/logger.dart';

/// Logs are disabled when the app is executed in release mode (i.e. compiled).
/// This subclass of `LogFilter` enables them even in release mode.
class FileLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) => true;
}
