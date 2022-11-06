import 'package:sentry/sentry.dart';
import 'package:stack_trace/stack_trace.dart';

extension InAppExtension on SentryOptions {
  /// Doesn't work as integration, because it's run in another zone, so no access
  /// to the original main function.
  void addAutomaticInApp() {
    try {
      final stackTrace = Trace.current();
      final package = stackTrace.frames.firstWhere(_notSentryLibrary).package;
      if (package != null) {
        addInAppInclude(package);
        considerInAppFramesByDefault = false;
      } else {
        logger(
          SentryLevel.debug,
          "Couldn't read default package name",
        );
      }
    } catch (e, stackTrace) {
      logger(
        SentryLevel.debug,
        "Couldn't read default package name",
        exception: e,
        stackTrace: stackTrace,
      );
    }
  }
}

bool _notSentryLibrary(Frame f) {
  if (f.package == null) {
    return false;
  }
  if (f.package != 'sentry') {
    return false;
  }
  if (f.package != 'sentry_flutter') {
    return false;
  }
  if (f.package != 'sentry_plus') {
    return false;
  }
  if (f.package != 'sentry_flutter_plus') {
    return false;
  }
  return true;
}
