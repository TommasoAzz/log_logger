import 'package:logger/logger.dart' show LogPrinter, LogEvent, Level;
import 'package:intl/intl.dart' show DateFormat;

/// Printer to use in the [printer] field of `Logger` when instantiated.
///
/// Like the name says, it's to be used when printing logs into a file. It can be also used for printing into console.
class FileLogPrinter extends LogPrinter {
  /// Date format to be used.
  static const String _dateFormat = 'dd/MM/yy HH:mm:ss';

  /// Labels to be printed to show the gravity of the log message.
  static const Map<Level, String> _level = {
    Level.nothing: '  -  ',
    Level.verbose: ' ... ',
    Level.debug: 'DEBUG',
    Level.info: 'INFO ',
    Level.warning: 'WARN ',
    Level.error: 'ERROR',
    Level.wtf: ' WTF '
  };

  /// Nome della classe che utilizza il logger istanziato.
  final String label;

  /// A [label] is required for displaying who the logger is printing for.
  FileLogPrinter(this.label);

  @override
  List<String> log(final LogEvent event) {
    return [
      '[${_level[event.level]}] [${DateFormat(_dateFormat).format(DateTime.now())} -- $label]:\t${event.message}',
    ];
  }
}
