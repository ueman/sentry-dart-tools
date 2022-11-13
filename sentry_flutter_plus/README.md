# Sentry Flutter Plus

[![pub package](https://img.shields.io/pub/v/sentry_flutter_plus.svg)](https://pub.dev/packages/sentry_flutter_plus) [![likes](https://img.shields.io/pub/likes/sentry_flutter_plus)](https://pub.dev/packages/sentry_flutter_plus/score) [![popularity](https://img.shields.io/pub/popularity/sentry_flutter_plus)](https://pub.dev/packages/sentry_flutter_plus/score) [![pub points](https://img.shields.io/pub/points/sentry_flutter_plus)](https://pub.dev/packages/sentry_flutter_plus/score)

This package includes a collection of community maintained integrations for Sentry.

Consider using [`sentry_plus`](https://pub.dev/packages/sentry_plus) for additionaly integrations.

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

## In App Exclude integration

Marks dependencies automatically as not in app for stacktraces.

## MethodChannel integration

Automatically collect breadcrumbs and performance traces for platform communication through MethodChannels.

# Manual integrations

## `SentryBinaryMessenger`

> **Note**
> There's also the automatic integration available for this. 
> Make sure to not use both.

This can be used to monitor messages from native to Flutter through message channels.

```dart
final channel = MethodChannel('method_channel_name', const StandardMethodCodec(), SentryBinaryMessenger());
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
