import 'package:sentry_connectivity/sentry_connectivity.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  SentryFlutter.init((options) {
    options.addIntegration(ConnectivityIntegration());
  });
}
