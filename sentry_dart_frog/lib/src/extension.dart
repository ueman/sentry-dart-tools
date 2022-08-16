import 'package:sentry/sentry.dart';

/// Extensions for Dart Frog
extension SentryDartFrogExtension on SentryOptions {
  /// Make stacktraces on Sentry.io look nicer
  void addDartFrogInAppExcludes() {
    addInAppExclude('shelf');
    addInAppExclude('dart_frog');
    addInAppExclude('sentry_dart_frog');
  }
}
