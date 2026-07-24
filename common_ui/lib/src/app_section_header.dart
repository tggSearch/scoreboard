import 'package:flutter/material.dart';
import 'ui_tokens.dart';

class AppSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? iconColor;
  final Color? iconBackgroundColor;

  const AppSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.iconColor,
    this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final resolvedIconColor = iconColor ?? primary;
    final resolvedBgColor =
        iconBackgroundColor ?? primary.withValues(alpha: 0.1);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(UiSpacing.sm),
          decoration: BoxDecoration(
            color: resolvedBgColor,
            borderRadius: BorderRadius.circular(UiRadius.sm),
          ),
          child: Icon(icon, color: resolvedIconColor, size: 20),
        ),
        const SizedBox(width: UiSpacing.md),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: UiColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
