import 'dart:io';

import 'package:sentry/sentry.dart';

import 'sentry_http_overrides.dart';

void addHttpTracing(SentryOptions options) {
  HttpOverrides.global = SentryHttpOverrides(HubAdapter(), options);
}
