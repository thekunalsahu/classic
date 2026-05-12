// lib/core/utils.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AppUtils {
  static Widget smoothFade({
    required Widget child,
    Duration duration = const Duration(milliseconds: 600),
    Curve curve = Curves.easeOutCubic,
    Duration delay = Duration.zero,
  }) {
    return child.animate().fadeIn(
      duration: duration,
      curve: curve,
      delay: delay,
    );
  }
}
