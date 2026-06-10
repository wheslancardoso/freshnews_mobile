import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

extension FNAnimations on Widget {
  Widget fnFadeUp({
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 400),
    double offsetY = 24,
  }) {
    return animate(delay: delay)
        .fadeIn(duration: duration, curve: Curves.easeOut)
        .slideY(
          begin: offsetY / 100,
          end: 0,
          duration: duration,
          curve: Curves.easeOut,
        );
  }

  Widget fnFade({
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return animate(delay: delay)
        .fadeIn(duration: duration, curve: Curves.easeOut);
  }

  Widget fnPop({
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 350),
  }) {
    return animate(delay: delay)
        .scale(
          begin: const Offset(0.88, 0.88),
          end: const Offset(1, 1),
          duration: duration,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: duration ~/ 2);
  }

  Widget fnShimmer({Color? baseColor, Color? highlightColor}) {
    return animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: const Duration(milliseconds: 1200),
          color: highlightColor ?? Colors.white.withOpacity(0.08),
        );
  }

  Widget fnStagger(int index, {int baseDelayMs = 60}) {
    return fnFadeUp(delay: Duration(milliseconds: baseDelayMs * index));
  }
}

class FNDuration {
  FNDuration._();
  static const fast   = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 300);
  static const slow   = Duration(milliseconds: 500);
  static const xslow  = Duration(milliseconds: 800);
}

class FNCurves {
  FNCurves._();
  static const enter  = Curves.easeOut;
  static const exit   = Curves.easeIn;
  static const spring = Curves.elasticOut;
  static const smooth = Curves.easeInOutCubic;
}
