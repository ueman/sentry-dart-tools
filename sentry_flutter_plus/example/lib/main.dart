import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sentry_flutter_plus/sentry_flutter_plus.dart';

void main() {
  // Needs to be called here, since I can't replace SentryFlutters internal
  // calls to the widget binding
  WidgetsSentryBinding.ensureInitialized();
  SentryFlutter.init((options) {
    options.dsn =
        'https://c8f216b28d814d2ca83e52fb735da535@o266569.ingest.sentry.io/5558444';
    options.tracesSampleRate = 1;
    options.addSentryFlutterPlus();
    options.debug = true;
    options.enablePrintBreadcrumbs = false;
    options.addIntegration(TreeWalkerIntegration());
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sentry Flutter Plus Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Sandbox'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return PlatformMenuBar(
      menus: <PlatformMenuItem>[
        PlatformMenu(
          label: 'Various',
          menus: <PlatformMenuItem>[
            PlatformMenuItemGroup(
              members: <PlatformMenuItem>[
                PlatformMenuItem(
                  label: 'About',
                  onSelected: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Example',
                    );
                  },
                )
              ],
            ),
            PlatformMenuItemGroup(
              members: <PlatformMenuItem>[
                PlatformMenuItem(
                  onSelected: () {
                    Sentry.captureException(Exception());
                  },
                  label: 'Capture Exception',
                ),
              ],
            ),
            if (PlatformProvidedMenuItem.hasMenu(
                PlatformProvidedMenuItemType.quit))
              const PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.quit),
            if (PlatformProvidedMenuItem.hasMenu(
                PlatformProvidedMenuItemType.about))
              const PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.about),
          ],
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  await Future.delayed(const Duration(milliseconds: 500));
                  throw Exception('Oh no');
                },
                child: const Text(
                  'PlatformDispatcher.onError '
                  '(works only on Flutter >= 3.1.0) '
                  'thrown as uncaught exception',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Sentry.captureMessage('WidgetTreeAttachment',
                      withScope: (scope) {
                    scope.addAttachment(WidgetTreeAttachment());
                  });
                },
                child: const Text(
                  'WidgetTreeAttachment',
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final transaction = Sentry.startTransaction(
                    'platform-communication',
                    'platform-communication',
                  );

                  // PackageInfo does some MethodChannel communication
                  // ignore: unused_local_variable
                  final info = await PackageInfo.fromPlatform();

                  await transaction.finish(status: const SpanStatus.ok());
                  throw Exception('with method channel breadcrumb');
                },
                child: const Text(
                  'MethodChannel communication',
                ),
              ),
              ElevatedButton(
                key: const Key('exception_button'),
                onPressed: () async {
                  if (kDebugMode) {
                    print('capture exception');
                  }
                  await Sentry.captureException(
                      Exception('Oh no, an exception ${DateTime.now()}'));
                },
                child: const Text('Oh no, an error'),
              ),
              ElevatedButton(
                key: const Key('tree walker'),
                onPressed: () async {
                  final tree =
                      TreeWalker(WidgetsBinding.instance.renderViewElement)
                          .compute()
                          ?.toString();

                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: SingleChildScrollView(
                          child: Text(tree ?? 'Error'),
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () =>
                                Clipboard.setData(ClipboardData(text: tree)),
                            child: const Text('Copy to clipboard'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('execute tree walker'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
