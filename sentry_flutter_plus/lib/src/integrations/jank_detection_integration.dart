import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sentry_flutter_plus/src/utils/frame_timings_summary.dart';

class JankDetectionIntegration extends Integration<SentryFlutterOptions> {
  JankDetectionIntegration({
    this.rasterJankDuration = const Duration(milliseconds: 16),
    this.buildJankDuration = const Duration(milliseconds: 16),
  });

  final Duration rasterJankDuration;
  final Duration buildJankDuration;

  @override
  void call(Hub hub, SentryFlutterOptions options) {
    WidgetsBinding.instance.addTimingsCallback(callback);
    options.sdk.addIntegration('JankDetectionIntegration');
  }

  @override
  void close() {
    WidgetsBinding.instance.removeTimingsCallback(callback);
  }

  void callback(List<FrameTiming> timings) {
    bool hasRasterJank = false;
    bool hasBuildJank = false;
    for (final frameTiming in timings) {
      if (frameTiming.rasterDuration > rasterJankDuration) {
        hasRasterJank = true;
      }

      if (frameTiming.buildDuration > buildJankDuration) {
        hasBuildJank = true;
      }
    }

    if (hasRasterJank || hasBuildJank) {
      Sentry.captureException(
        JankDetectedException(
          timings,
          rasterJankDuration,
          buildJankDuration,
        ),
        withScope: (scope) {
          scope.setExtra(
              'frame_summary', FrameTimingSummarizer(timings).summary);
        },
      );
    }
  }
}

class JankDetectedException implements Exception {
  JankDetectedException(
    this.frameTimings,
    this.rasterJankDuration,
    this.buildJankDuration,
  );

  final List<FrameTiming> frameTimings;
  final Duration rasterJankDuration;
  final Duration buildJankDuration;

  @override
  String toString() {
    final frameTimingsString = frameTimings.join('\n');
    final duration = frameTimings
        .map((it) => it.totalSpan)
        .reduce((value, element) => value + element);

    return 'Detected jank within the last $duration. '
        'This exception was reported because the frametimings exceeded '
        '$rasterJankDuration for rasterization or $buildJankDuration for '
        'the build of the frame.\n'
        '\n'
        'Find more elaborate data in the `frame_summary` extra.'
        '\n'
        'The following are the frames relevant frames:\n'
        '$frameTimingsString\n';
  }
}
