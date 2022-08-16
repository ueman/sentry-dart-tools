# Sentry for dart_frog

This is an integration for [`dart_frog`](https://pub.dev/packages/dart_frog) to collect errors and automatically report them to Sentry.

> **Note**
> This is experimental. Use at your own risk.

## How to use it?

First add a custom entry point and initialize Sentry as shown in the follwing code snippet. To know more about a custom entry point, read [this](https://dartfrog.vgv.dev/docs/advanced/custom_entrypoint).
```dart
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
    final mechanism = Mechanism(type: 'runZonedGuarded', handled: false);
    final throwableMechanism = ThrowableMechanism(mechanism, error);

    final event = SentryEvent(
      throwable: throwableMechanism,
      level: SentryLevel.fatal,
    );

    Sentry.captureEvent(event, stackTrace: stack);
  })!;
}
```

Secondly, add the `sentryMiddleware` as shown in the following code snippet. Read more about middlewares [here](https://dartfrog.vgv.dev/docs/basics/middleware). 
```dart
// _middleware.dart
Handler middleware(Handler handler) {
  return handler
      // add Sentry middleware
      .use(sentryMiddleware);
}
```