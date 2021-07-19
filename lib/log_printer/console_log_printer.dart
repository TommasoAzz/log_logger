import 'package:logger/logger.dart';
import 'package:intl/intl.dart' show DateFormat;

/// Printer to use in the [printer] field of `Logger` when instantiated.
///
/// Like the name says, it's to be used when printing logs in the console.
/// It's not great to be used for writing to file due to the emojis and colors.
class ConsoleLogPrinter extends LogPrinter {
  /// Date format to be used.
  static const String _date_format = 'dd/MM/yy HH:mm:ss';

  /// Emojis to be printed to graphically show the gravity of the log message.
  static const Map<Level, String> levelEmojis = {
    Level.nothing: '  ',
    Level.verbose: '💬 ',
    Level.debug: '🐛 ',
    Level.info: '💡 ',
    Level.warning: '⚠️ ',
    Level.error: '⛔ ',
    Level.wtf: '👾 ',
  };

  /// Label for the log line.
  final String label;

  /// A [label] is required for displaying who the logger is printing for.
  ConsoleLogPrinter(this.label);

  @override
  List<String> log(final LogEvent event) {
    /// Color of the log line in the console.
    final color = PrettyPrinter.levelColors[event.level]!;

    /// Emoji in the line of text of the log to begin the line (indicative).
    final emoji = levelEmojis[event.level]!;

    return [
      color(
        '$emoji [${DateFormat(_date_format).format(DateTime.now())} -- $label]:\t${event.message}',
      )
    ];
  }
}
