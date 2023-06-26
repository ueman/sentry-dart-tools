import 'package:sentry/sentry.dart';

extension InAppExclueds on SentryOptions {
  void addSentryLinkInAppExcludes() {
    addInAppExclude('sentry_link');
  }
}
