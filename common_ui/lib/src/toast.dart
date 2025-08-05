import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Toast {
  static void show(String message, {
    Duration duration = const Duration(seconds: 2),
    Color backgroundColor = Colors.black87,
    Color textColor = Colors.white,
    double fontSize = 16.0,
  }) {
    Get.snackbar(
      '',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor,
      colorText: textColor,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      titleText: const SizedBox.shrink(),
      messageText: Text(
        message,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  static void success(String message) {
    show(
      message,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  static void error(String message) {
    show(
      message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  static void warning(String message) {
    show(
      message,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
    );
  }

  static void info(String message) {
    show(
      message,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
    );
  }
} 