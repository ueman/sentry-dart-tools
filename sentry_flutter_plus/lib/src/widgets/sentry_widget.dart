import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sentry_flutter_plus/src/widgets/click_tracker.dart';
import 'package:sentry_flutter_plus/src/widgets/sentry_screenshot.dart';

class SentryWidget extends StatelessWidget {
  const SentryWidget({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SentryScreenshot(
      child: ClickTracker(
        child: DefaultAssetBundle(
          bundle: SentryAssetBundle(bundle: rootBundle),
          child: child,
        ),
      ),
    );
  }
}
