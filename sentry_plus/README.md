# Sentry Plus


[![pub package](https://img.shields.io/pub/v/sentry_plus.svg)](https://pub.dev/packages/sentry_plus) [![likes](https://img.shields.io/pub/likes/sentry_plus)](https://pub.dev/packages/sentry_plus/score) [![popularity](https://img.shields.io/pub/popularity/sentry_plus)](https://pub.dev/packages/sentry_plus/score) [![pub points](https://img.shields.io/pub/points/sentry_plus)](https://pub.dev/packages/sentry_plus/score)

This package includes a collection of community maintained integrations for Sentry.

# Automatic integrations

## Add all automatic integrations

```dart
import 'package:sentry_plus/sentry_plus.dart';

Future<void> main() {
  // also works for SentryFlutter.init
  return Sentry.init(
    (options) {
      options.addSentryPlus();
      // other configuration omitted
    },
    appRunner: () {
        // app code
    },
  );
}
```

## File tracing

Use the [official file tracing package from Sentry](https://pub.dev/packages/sentry_file).

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
  // also works for SentryFlutter.init
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

## `UnhandledEventProcessor`

This event processor marks all exceptions caught by Sentry as `unhandled:  true`. This kinda goes against Sentrys typical usage of it, as `unhandled:  true` means that the application did a hard crash, which Flutter applications
typically don't do.

```dart
import 'package:sentry_plus/sentry_plus.dart';

Future<void> main() {
  // also works for SentryFlutter.init
  return Sentry.init(
    (options) {
      options.addEventProcessor(UnhandledEventProcessor());
      // other configuration omitted
    },
    appRunner: () {
        // app code
    },
  );
}
```

# Manual integrations

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
- When comparable features are implemented in (or moved to) Sentry, it will be removed from this package.
- Features & integrations should be easy to integrate and use

## 📣 About the author

- [![Twitter Follow](https://img.shields.io/twitter/follow/ue_man?style=social)](https://twitter.com/ue_man)
- [![GitHub followers](https://img.shields.io/github/followers/ueman?style=social)](https://github.com/ueman)
