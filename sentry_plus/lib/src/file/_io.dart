import 'dart:io';

import 'package:sentry/sentry.dart';
import 'package:sentry_plus/src/file/sentry_io_overrides.dart';

void addFileTracing(SentryOptions options) {
  IOOverrides.global = SentryIoOverrides(HubAdapter(), options);
}
