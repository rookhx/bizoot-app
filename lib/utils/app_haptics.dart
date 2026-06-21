import 'package:flutter/services.dart';

class AppHaptics {
  static Future<void> tap() => HapticFeedback.lightImpact();

  static Future<void> success() => HapticFeedback.mediumImpact();

  static Future<void> delete() => HapticFeedback.heavyImpact();

  static Future<void> warning() => HapticFeedback.selectionClick();
}
