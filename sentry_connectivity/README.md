# Sentry Connectivity

[![pub package](https://img.shields.io/pub/v/sentry_connectivity.svg)](https://pub.dev/packages/sentry_connectivity) [![likes](https://img.shields.io/pub/likes/sentry_connectivity)](https://pub.dev/packages/sentry_connectivity/score) [![popularity](https://img.shields.io/pub/popularity/sentry_connectivity)](https://pub.dev/packages/sentry_connectivity/score) [![pub points](https://img.shields.io/pub/points/sentry_connectivity)](https://pub.dev/packages/sentry_connectivity/score)


## Features

This package adds breadcrumbs for network changes to Sentry.

## Getting started

Add this package to the `pubspec.yaml` file. Follow the instructions from [`connectivity_plus`](https://pub.dev/packages/connectivity_plus) (which is used by this library under the hood) if needed.

## Usage

```dart
import 'package:sentry_connectivity/sentry_connectivity.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  SentryFlutter.init((options) {
    options.addIntegration(ConnectivityIntegration());
  });
}
```