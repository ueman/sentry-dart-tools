import 'dart:async';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:sentry/sentry.dart';

/// Starts an [HttpServer] that listens on the specified [address] and
/// [port] and sends requests to [handler].
///
/// Adds error handling via Sentry.
///
/// Pass [poweredByHeader] to set the default content for "X-Powered-By",
/// pass `null` to omit this header.
///
///  If a [securityContext] is provided an HTTPS server will be started
Future<HttpServer> serveWithSentry(
  Handler handler,
  Object address,
  int port, {
  String? poweredByHeader = 'Dart with package:dart_frog',
  SecurityContext? securityContext,
}) async {
  return await runZonedGuarded(() {
    return serve(
      handler,
      address,
      port,
      poweredByHeader: poweredByHeader,
      securityContext: securityContext,
    );
  }, (error, stack) {
    final mechanism = Mechanism(type: 'runZonedGuarded', handled: false);
    final throwableMechanism = ThrowableMechanism(mechanism, error);

    final event = SentryEvent(
      throwable: throwableMechanism,
      level: SentryLevel.fatal,
    );

    Sentry.captureEvent(event, stackTrace: stack);
  })!;
}
