import 'dart:async';
import 'dart:io';

import 'package:logger/logger.dart' show LogOutput, OutputEvent;
import 'package:synchronized/synchronized.dart';

/// [SynchronizedFileOutput] enables the logging to a text file.
///
/// Since the [void output(OutputEvent event)] method is synchronous in the interface `LogOutput`
/// an intermediate stream is used to handle write requests to the output file that
/// get performed only if the file is not being written. This is implemented with a
/// blocking-IO mechanism enabled by the class `Lock` of the library `synchronized`.
class SynchronizedFileOutput implements LogOutput {
  /// File in which to write the logging output.
  File _file;

  /// Lock instance.
  final Lock _fileLock = Lock();

  /// The stream controller for writing into the file.
  final StreamController<String> _controller = StreamController<String>();

  /// A [File] instance is required for enabling this type of `LogOutput`.
  SynchronizedFileOutput(this._file);

  /// Writes a single line to the file.
  Future<void> _writeLogLineToFile(final String logLine) async {
    // Start of the critical region.
    await _file.writeAsString(logLine, mode: FileMode.append, flush: true);
    // End of the critical region
  }

  /// Writes [logLine] to the file protected by a critical region.
  Future<void> _synchronizedWrite(final String logLine) async {
    await _fileLock.synchronized(() => _writeLogLineToFile("$logLine\n"));
  }

  /// Opens the file that was given as a reference in the constructor (and creates it if it does not exist).
  @override
  void init() async {
    if (!(await _file.exists())) {
      _file = await _file.create();
    }
    _controller.stream.listen(_synchronizedWrite);
  }

  /// Outputs the first line of [event.lines] in the file.
  @override
  void output(OutputEvent event) {
    _controller.sink.add(event.lines[0]);
  }

  /// Destroys the stream controller.
  @override
  void destroy() async {
    await _controller.close();
  }
}
