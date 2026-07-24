import 'package:flutter/material.dart';
import 'ui_tokens.dart';

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.message,
    this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UiSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(UiSpacing.xl),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: primary.withValues(alpha: 0.5)),
            ),
            if (title != null) ...[
              const SizedBox(height: UiSpacing.lg),
              Text(
                title!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: UiColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: UiSpacing.sm),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: UiColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: UiSpacing.xxl),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
