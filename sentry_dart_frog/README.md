# Sentry for dart_frog

This is an integration for [`dart_frog`](https://pub.dev/packages/dart_frog) to collects errors and performance traces automatically.

Learn more in this [article](https://medium.com/@jonasuekoetter/bridging-the-gap-distributed-tracing-for-flutter-and-backend-4943799b0ea9).

> **Note**
> This is experimental. Use at your own risk.

## How to use it?

First add a custom entry point and initialize Sentry as shown in the follwing code snippet. To know more about a custom entry point, read [this](https://dartfrog.vgv.dev/docs/advanced/custom_entrypoint).
```dart
// main.dart
Future<HttpServer> init(Handler handler, InternetAddress ip, int port) async {
  await Sentry.init((options) {
    options
      ..dsn = '<your_dsn_here>'
      ..tracesSampleRate = 1
      ..addDartFrogInAppExcludes();
  });
}

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) {
  return serveWithSentry(handler, ip, port);
}
```

Secondly, add the `sentryMiddleware` as shown in the following code snippet. Read more about middlewares [here](https://dartfrog.vgv.dev/docs/basics/middleware). 
```dart
// _middleware.dart
Handler middleware(Handler handler) {
  // add Sentry middleware
  return handler.use(sentryMiddleware);
}
```