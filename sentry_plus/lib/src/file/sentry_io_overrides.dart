import 'dart:io';
import 'package:sentry/sentry.dart';

import 'sentry_file.dart';

class SentryIoOverrides extends IOOverrides {
  final Hub _hub;
  final SentryOptions _options;

  SentryIoOverrides(this._hub, this._options);

  // Probably also interesting
  // @override
  // Directory createDirectory(String path) => super.createDirectory(path);

  @override
  File createFile(String path) {
    if (!_options.isTracingEnabled()) {
      return super.createFile(path);
    }
    return SentryFile(
      super.createFile(path),
      _hub,
      _options,
    );
  }
}
