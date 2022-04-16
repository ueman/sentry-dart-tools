# Sentry Plus

This package includes a collection of community maintained integrations for Sentry.

## File tracing

This enables automatic creation of performance traces for most file IO.
It includes traces for reading, writing, modifying and deleting files.

This is only available on non-web platforms.

## HTTP tracing

Enable automatic creation of performance traces for HTTP requests for `dart:io` platforms.

* This also works for the `http` and `dio` packages.
* This also captures requests from Flutters `Image.network` widget

This is only available on non-web platforms.

Remarks: 
Make sure to disable performance tracing for the `http` or `dio` packages, if you're using them. Otherwise you're creating two traces for the same request.

## Getting started

Follow the guidelines from the official Sentry package for Dart or Flutter
and then add the following:

```dart
Future<void> main() {
  return Sentry.init(
    (options) {
      options.dsn = '<your DSN here>';
      options.addFileTracing();
      options.addHttpTracing();
    },
    appRunner: () {
        // app code
    },
  );
}
```