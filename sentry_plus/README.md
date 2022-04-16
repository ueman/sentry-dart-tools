# Sentry Plus

> Please note, that this code isn't fully unit tested, but it should already work quite well.

This package includes a collection of community maintained integrations for Sentry.

## File tracing

This enables automatic creation of performance traces for most file IO.
It includes traces for reading, writing, modifying and deleting files.

This is only available on non-web platforms.

```dart
import 'package:sentry_plus/sentry_plus.dart';

Future<void> main() {
  return Sentry.init(
    (options) {
      // Add tracing for files
      options.addFileTracing();
      // other configuration omitted
    },
    appRunner: () {
        // app code
    },
  );
}
```

## HTTP tracing

Enable automatic creation of performance traces for HTTP requests for `dart:io` platforms.

* This also works for the `http` and `dio` packages.
* This also captures requests from Flutters `Image.network` widget

This is only available on non-web platforms.

Remarks: 
Make sure to disable performance tracing for the `http` or `dio` packages, if you're using them. Otherwise you're creating two traces for the same request.

```dart
import 'package:sentry_plus/sentry_plus.dart';

Future<void> main() {
  return Sentry.init(
    (options) {
      // Add tracing for http
      options.addHttpTracing();
      // other configuration omitted
    },
    appRunner: () {
        // app code
    },
  );
}
```

## `dart:convert`

This repo includes some utilities to make it easier to add performance traces
for conversion done by `dart:convert`.

```dart
import 'package:sentry_plus/sentry_plus.dart';

final List<int> data = [/* ...*/];
// call the extension method `wrapWithTraces()` on a codec or converter
final decoder = utf8.decoder.wrapWithTraces();
final converted = decoder.convert(data);
```