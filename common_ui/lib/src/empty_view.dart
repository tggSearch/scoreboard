import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_empty_state.dart';

class EmptyView extends StatelessWidget {
  final String? title;
  final String? message;
  final IconData? icon;
  final VoidCallback? onRetry;
  final String? retryText;

  const EmptyView({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.onRetry,
    this.retryText,
  });

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: icon ?? Icons.inbox_outlined,
      title: title,
      message: message ?? '',
      actionLabel: onRetry != null ? (retryText ?? 'retry'.tr) : null,
      onAction: onRetry,
    );
  }
}

class EmptyViewBuilder {
  static Widget networkError({VoidCallback? onRetry}) {
    return EmptyView(
      icon: Icons.wifi_off,
      title: 'network_connection_failed'.tr,
      message: 'please_check_network_and_retry'.tr,
      onRetry: onRetry,
      retryText: 'retry'.tr,
    );
  }

  static Widget noData({String? message}) {
    return EmptyView(
      icon: Icons.inbox_outlined,
      message: message ?? 'no_data'.tr,
    );
  }

  static Widget error({String? message, VoidCallback? onRetry}) {
    return EmptyView(
      icon: Icons.error_outline,
      title: 'error'.tr,
      message: message ?? 'unknown_error'.tr,
      onRetry: onRetry,
      retryText: 'retry'.tr,
    );
  }
}
