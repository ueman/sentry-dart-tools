import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sentry_plus/sentry_plus.dart';
import 'package:sentry/sentry.dart';

Future<void> main() {
  return Sentry.init(
    (options) {
      options.dsn =
          'https://c8f216b28d814d2ca83e52fb735da535@o266569.ingest.sentry.io/5558444';
      options.tracesSampleRate = 1;
      options.addFileTracing();
      options.addHttpTracing();
      options.addEventProcessor(UnhandledEventProcessor());
      options.addAutomaticInApp();
    },
    appRunner: executeProgramm,
  );
}

void executeProgramm() async {
  final trx = Sentry.startTransaction(
    'test',
    'foo-bar-operation',
    bindToScope: true,
  );
  var client = HttpClient();
  try {
    HttpClientRequest request = await client.get('flutter.dev', 80, '/');

    HttpClientResponse response = await request.close();
    final stringData =
        await response.transform(utf8.decoder.wrapWithTraces()).join();
    print(stringData);
  } finally {
    client.close();
  }

  final List<int> data = [/* ...*/];
  final decoder = utf8.decoder.wrapWithTraces();
  // ignore: unused_local_variable
  final converted = decoder.convert(data);

  print('finished http request');
  print('starting writing files');

  final file = File(join(Directory.current.path, 'foobar.txt'));
  print('Writing file at ${file.path}');
  await file.writeAsString(
    'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.',
  );
  print('Deleting file at ${file.path}');
  await file.delete();

  await trx.finish();

  print('finished writing and deleting files');
  exit(0);
}
