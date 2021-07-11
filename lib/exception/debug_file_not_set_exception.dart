/// Exception thrown when the debug file in the [LogLogger] class is not set before
/// requiring the debug mode active.
class DebugFileNotSetException implements Exception {
  final String _message;

  const DebugFileNotSetException(this._message);

  @override
  String toString() => 'DebugFileNotSetException: $_message';
}
