import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            if (message != null) ...[
              Text(
                message!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
            if (onRetry != null) ...[
              ElevatedButton(
                onPressed: onRetry,
                child: Text(retryText ?? 'retry'.tr),
              ),
            ],
          ],
        ),
      ),
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
      title: 'no_data'.tr,
      message: message ?? 'no_related_data_temporarily'.tr,
    );
  }

  static Widget error({String? message, VoidCallback? onRetry}) {
    return EmptyView(
      icon: Icons.error_outline,
      title: 'load_failed'.tr,
      message: message ?? 'data_load_failed_please_retry'.tr,
      onRetry: onRetry,
      retryText: 'retry'.tr,
    );
  }
} 