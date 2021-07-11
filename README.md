# LogLogger

Wrapper of the [logger](https://pub.dev/packages/logger) library available on [pub.dev](https://pub.dev).
Everything you can do with **logger** is supported here but with a more convenient way to log messages into a text file.

## Getting Started

In order to use the logging functionalities, you need to get a logger:

```dart
LogLogger.setMinimumLogLevel(LoggerLevel.verbose);
final logger = LogLogger.getLogger('loggerName');
logger.i('I am a logger called loggerName!');
```

