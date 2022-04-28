import 'dart:io';

import 'package:sentry/sentry.dart';

import 'sentry_io_http_client.dart';

class SentryHttpOverrides extends HttpOverrides {
  final Hub _hub;
  final SentryOptions _options;

  SentryHttpOverrides(this._hub, this._options);

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    var innerClient = super.createHttpClient(context);
    if (!_options.isTracingEnabled()) {
      return innerClient;
    }
    return SentryIoHttpClient(_options, _hub, innerClient);
  }
}
