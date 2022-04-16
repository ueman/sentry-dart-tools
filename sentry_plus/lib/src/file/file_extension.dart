import 'package:sentry/sentry.dart';
import '_io.dart' if (dart.library.html) '_no_op.dart' as file_tracer;

extension SentryFileExtension on SentryOptions {
  void addFileTracing() {
    file_tracer.addFileTracing(this);
  }
}
