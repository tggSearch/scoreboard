import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography scale for the app.
abstract final class AppTextStyles {
  static TextStyle get display => const TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get headline => const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get title => const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.35,
      );

  static TextStyle get titleSmall => const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.35,
      );

  static TextStyle get body => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodySmall => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  static TextStyle get label => const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get caption => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  static TextStyle score({double size = 48, Color? color}) {
    return TextStyle(
      fontSize: size,
      fontWeight: FontWeight.bold,
      fontFamily: 'monospace',
      color: color ?? AppColors.textPrimary,
      height: 1.1,
    );
  }

  static TextStyle timer({double size = 24}) {
    return TextStyle(
      fontSize: size,
      fontWeight: FontWeight.bold,
      fontFamily: 'monospace',
      color: AppColors.textPrimary,
      height: 1.2,
    );
  }
}
