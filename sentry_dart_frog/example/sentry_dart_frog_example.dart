import 'package:sentry_dart_frog/sentry_dart_frog.dart';

import 'dart:async';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:sentry/sentry.dart';

// main.dart
Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  await Sentry.init((options) {
    options
      ..dsn = '<your_dsn_here>'
      ..tracesSampleRate = 1
      ..addDartFrogInAppExcludes();
  });
  return await runZonedGuarded(() {
    return serve(handler, ip, port);
  }, (error, stack) {
    final mechanism = Mechanism(type: 'runZonedGuarded', handled: true);
    final throwableMechanism = ThrowableMechanism(mechanism, error);

    final event = SentryEvent(
      throwable: throwableMechanism,
      level: SentryLevel.fatal,
    );

    Sentry.captureEvent(event, stackTrace: stack);
  })!;
}

// _middleware.dart
Handler middleware(Handler handler) {
  return handler
      // add all Sentry middleware
      .use(sentryMiddleware);
}
