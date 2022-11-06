import 'dart:async';

import 'package:sentry/sentry.dart';

/// Mark every exception as unhandled which is not handled by user code.
class UnhandledEventProcessor implements EventProcessor {
  @override
  FutureOr<SentryEvent?> apply(SentryEvent event, {hint}) {
    final throwableMechanism = event.throwableMechanism;
    if (throwableMechanism is! ThrowableMechanism) {
      return event;
    }
    final type = throwableMechanism.mechanism.type;
    if (type != 'runZonedGuarded' && type != 'FlutterError') {
      return event;
    }
    // set handled = false
    return event.copyWith(
      throwable: ThrowableMechanism(
        throwableMechanism.mechanism.copyWith(
          handled: false,
        ),
        throwableMechanism.throwable,
      ),
    );
  }
}
