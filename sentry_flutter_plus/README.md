# Sentry Flutter Plus

This package includes a collection of community maintained integrations for Sentry.

This also includes [`sentry_plus`](https://pub.dev/packages/sentry_plus).

# Automatic integrations

## Even more event enrichment

This includes even more information for event.
- Environment information for Windows
- Environment information for Linux
- More information which is available in newer Flutter versions.

## Add all automatic integrations

```dart
import 'package:sentry_flutter_plus/sentry_flutter_plus.dart';

Future<void> main() {
  return SentryFlutter.init(
    (options) {
      options.addSentryFlutterPlus();
      // other configuration omitted
    },
    appRunner: () {
        // app code
    },
  );
}
```

## PlatformMenu integration

Adds automatic breadcrumbs for selecting platform menu (see [PlatformMenuBar](https://api.flutter.dev/flutter/widgets/PlatformMenuBar-class.html)).

## `PlatformDispatcher.onError` error handler

> **Note**
> This is not yet available on the Flutter stable channel

Automatic collection of exceptions reported to [`PlatformDispatcher.onError`](https://master-api.flutter.dev/flutter/dart-ui/PlatformDispatcher/onError.html).

## In App Exclude integration

Marks dependencies automatically as not in app for stacktraces.

# Manual integrations

## `SentryBinaryMessenger`

This can be used to monitor messages from native to Flutter through message channels.

```dart
final channel = MethodChannel('method_channel_name', const StandardMethodCodec(), SentryBinaryMessenger());
```

# Debug only utilities

## `WidgetTreeAttachment`

> **Note**
> This is only works in debug mode.

This is an attachment which show the current widget tree. 

```dart
Sentry.captureMessage('WidgetTreeAttachment',
  withScope: (scope) {
    scope.addAttachment(WidgetTreeAttachment());
});
```

## Design & support philosophy

This code differs from Sentrys design and support philosophy:
- This code doesn't try to be as backwards compatible as possible. This enables this code to make use of newer features.
- This code doesn't try to stay free of dependencies. Low quality dependencies are still not allowed, though.
- This code has no guarantees for API stability
- When comparable features are implemented in (or moved to) Sentry, it will be removed from this package.
- Features & integrations should be easy to integrate and use