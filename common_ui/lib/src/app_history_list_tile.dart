import 'package:flutter/material.dart';
import 'ui_tokens.dart';

class AppHistoryListTile extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final int? index;

  const AppHistoryListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: UiSpacing.md),
      decoration: BoxDecoration(
        color: UiColors.card,
        borderRadius: BorderRadius.circular(UiRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(UiRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(UiSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                leading ??
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: primary,
                      child: Text(
                        index != null ? '${index! + 1}' : '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                const SizedBox(width: UiSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: UiColors.textPrimary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: UiColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
