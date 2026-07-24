import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 安全关闭弹窗，避免 Get.back() 优先关闭 Snackbar 导致弹窗无法关闭。
class DialogNavigator {
  DialogNavigator._();

  static void close<T>([T? result, BuildContext? context]) {
    final navigator = _findNavigator(context);
    if (navigator != null && navigator.canPop()) {
      navigator.pop<T>(result);
    }
  }

  static NavigatorState? _findNavigator(BuildContext? context) {
    if (context != null) {
      return Navigator.maybeOf(context, rootNavigator: true);
    }

    final overlayContext = Get.overlayContext;
    if (overlayContext != null) {
      return Navigator.maybeOf(overlayContext, rootNavigator: true);
    }

    final getContext = Get.context;
    if (getContext != null) {
      return Navigator.maybeOf(getContext, rootNavigator: true);
    }

    return null;
  }

  static void closeThen(void Function() then, [BuildContext? context]) {
    close(null, context);
    Future.microtask(then);
  }
}
