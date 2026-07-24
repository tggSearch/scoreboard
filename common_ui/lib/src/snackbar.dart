import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ui_tokens.dart';

class CustomSnackbar {
  static void show(
    String title,
    String message, {
    SnackPosition position = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 3),
    Color backgroundColor = UiColors.textPrimary,
    Color textColor = Colors.white,
    Widget? icon,
  }) {
    _runWhenOverlayReady(() {
      if (Get.isSnackbarOpen) {
        Get.closeAllSnackbars();
      }
      Get.snackbar(
        title,
        message,
        snackPosition: position,
        backgroundColor: backgroundColor,
        colorText: textColor,
        duration: duration,
        margin: const EdgeInsets.all(UiSpacing.lg),
        borderRadius: UiRadius.md,
        icon: icon,
      );
    });
  }

  static void _runWhenOverlayReady(VoidCallback action, {int retryCount = 0}) {
    final context = Get.overlayContext ?? Get.context;
    if (context != null && Overlay.maybeOf(context) != null) {
      action();
      return;
    }

    if (retryCount >= 5) {
      debugPrint('Snackbar skipped: overlay not available');
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runWhenOverlayReady(action, retryCount: retryCount + 1);
    });
  }

  static void success(String title, String message) {
    show(
      title,
      message,
      backgroundColor: UiColors.primary,
      textColor: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  static void error(String title, String message) {
    show(
      title,
      message,
      backgroundColor: const Color(0xFFEF4444),
      textColor: Colors.white,
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  static void warning(String title, String message) {
    show(
      title,
      message,
      backgroundColor: const Color(0xFFF59E0B),
      textColor: Colors.white,
      icon: const Icon(Icons.warning, color: Colors.white),
    );
  }

  static void info(String title, String message) {
    show(
      title,
      message,
      backgroundColor: const Color(0xFF3B82F6),
      textColor: Colors.white,
      icon: const Icon(Icons.info, color: Colors.white),
    );
  }
}
