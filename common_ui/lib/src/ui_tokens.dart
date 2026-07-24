import 'package:flutter/material.dart';

/// Shared color tokens for common_ui (mirrors main app AppColors).
abstract final class UiColors {
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF43A047);
  static const Color surface = Color(0xFFF5F7FA);
  static const Color surfaceVariant = Color(0xFFEEF1F5);
  static const Color card = Colors.white;
  static const Color border = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
}

abstract final class UiSpacing {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
}

abstract final class UiRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
}
