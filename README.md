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

## What you can do to help

I developed this wrapper package since it can help other people in need of something similar.
Some stuff is missing, like for example the possibility to reuse the same reference of a logger even if the instance has changed
(I'm not sure if that is possible).
Please contribute with your PRs if you wish to!