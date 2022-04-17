# Sentry Plus

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

## Design & support philosophy

This code differs from Sentrys design and support philosophy:
- This code doesn't try to be as backwards compatible as possible. This enables this code to make use of newer features.
- This code doesn't try to stay free of dependencies. Low quality dependencies are still not allowed, though.
- This code has no guarantees for API stability
- Code is not supported by Sentry
- When comparable features are implemented in (or moved to) Sentry, it will be removed from this package.
- Features & integrations should be easy to integrate and use
