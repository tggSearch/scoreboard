import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSnackbar {
  static void show(String title, String message, {
    SnackPosition position = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 3),
    Color backgroundColor = Colors.black87,
    Color textColor = Colors.white,
    Widget? icon,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor: backgroundColor,
      colorText: textColor,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: icon,
    );
  }

  static void success(String title, String message) {
    show(
      title,
      message,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  static void error(String title, String message) {
    show(
      title,
      message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  static void warning(String title, String message) {
    show(
      title,
      message,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
      icon: const Icon(Icons.warning, color: Colors.white),
    );
  }

  static void info(String title, String message) {
    show(
      title,
      message,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      icon: const Icon(Icons.info, color: Colors.white),
    );
  }
} 