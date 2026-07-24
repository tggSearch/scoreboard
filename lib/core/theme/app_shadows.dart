import 'package:flutter/material.dart';

/// Shared elevation shadows.
abstract final class AppShadows {
  static List<BoxShadow> get sm => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get md => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get lg => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> primaryGlow(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.25),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];
}
