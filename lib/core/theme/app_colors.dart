import 'package:flutter/material.dart';

/// Central color tokens for the ScoreBoard design system.
abstract final class AppColors {
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF43A047);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color primaryMuted = Color(0xFF4CAF50);

  static const Color surface = Color(0xFFF5F7FA);
  static const Color surfaceVariant = Color(0xFFEEF1F5);
  static const Color card = Colors.white;
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);

  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  static const List<Color> primaryGradient = [
    Color(0xFF2E7D32),
    Color(0xFF43A047),
  ];

  static const List<Color> splashGradient = [
    Color(0xFF2E7D32),
    Color(0xFF43A047),
    Color(0xFF66BB6A),
  ];

  static const List<Color> heroGradient = [
    Color(0xFF2E7D32),
    Color(0xFF388E3C),
  ];
}
