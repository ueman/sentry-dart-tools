import 'package:sentry/sentry.dart';

/// Extensions for Dart Frog
extension SentryDartFrogExtension on SentryOptions {
  /// Make stacktraces on Sentry.io look nicer
  void addDartFrogInAppExcludes() {
    // dart frog and its dependencies
    addInAppExclude('shelf');
    addInAppExclude('shelf_hotreload');
    addInAppExclude('shelf_static');
    addInAppExclude('http_parser');
    addInAppExclude('http_methods');
    addInAppExclude('dart_frog');

    // First party packages to be used with dart_frog
    addInAppExclude('dart_frog_auth');
    addInAppExclude('dart_frog_web_socket');

    // This library
    addInAppExclude('sentry_dart_frog');
  }
}
