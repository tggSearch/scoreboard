import 'package:flutter/material.dart';
import 'ui_tokens.dart';

enum AppButtonVariant { primary, secondary, danger, warning, success }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool expanded;
  final bool compact;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.expanded = false,
    this.compact = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = _colors();

    final child = isLoading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: compact ? 16 : 18, color: fg),
                SizedBox(width: compact ? 6 : 8),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: compact ? 13 : 15,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ],
          );

    final button = Material(
      color: bg,
      borderRadius: BorderRadius.circular(compact ? UiRadius.md : UiRadius.lg),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(compact ? UiRadius.md : UiRadius.lg),
        child: Container(
          width: expanded ? double.infinity : null,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 14 : 20,
            vertical: compact ? 8 : 14,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(compact ? UiRadius.md : UiRadius.lg),
            border: border != null ? Border.all(color: border) : null,
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );

    return expanded ? button : button;
  }

  (Color, Color, Color?) _colors() {
    switch (variant) {
      case AppButtonVariant.primary:
        return (UiColors.primary, Colors.white, null);
      case AppButtonVariant.secondary:
        return (UiColors.surfaceVariant, UiColors.primary, UiColors.border);
      case AppButtonVariant.danger:
        return (const Color(0xFFFEE2E2), const Color(0xFFDC2626), const Color(0xFFFECACA));
      case AppButtonVariant.warning:
        return (const Color(0xFFFEF3C7), const Color(0xFFD97706), const Color(0xFFFDE68A));
      case AppButtonVariant.success:
        return (const Color(0xFFDCFCE7), const Color(0xFF16A34A), const Color(0xFFBBF7D0));
    }
  }
}

/// Compact toolbar action chip (add / delete / reset).
class AppActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;

  const AppActionChip({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    required this.color,
  });

  factory AppActionChip.add({required VoidCallback? onPressed, required String label}) {
    return AppActionChip(
      label: label,
      icon: Icons.add_rounded,
      onPressed: onPressed,
      color: UiColors.primary,
    );
  }

  factory AppActionChip.delete({required VoidCallback? onPressed, required String label}) {
    return AppActionChip(
      label: label,
      icon: Icons.delete_outline_rounded,
      onPressed: onPressed,
      color: const Color(0xFFDC2626),
    );
  }

  factory AppActionChip.reset({required VoidCallback? onPressed, required String label}) {
    return AppActionChip(
      label: label,
      icon: Icons.refresh_rounded,
      onPressed: onPressed,
      color: const Color(0xFFD97706),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(UiRadius.md),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(UiRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Circular step button for +/- score controls.
class AppStepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isIncrement;

  const AppStepButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.isIncrement = true,
  });

  factory AppStepButton.minus({VoidCallback? onPressed}) {
    return AppStepButton(
      icon: Icons.remove_rounded,
      onPressed: onPressed,
      isIncrement: false,
    );
  }

  factory AppStepButton.plus({VoidCallback? onPressed}) {
    return AppStepButton(
      icon: Icons.add_rounded,
      onPressed: onPressed,
      isIncrement: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = isIncrement ? UiColors.primary : const Color(0xFFDC2626);
    final bg = isIncrement
        ? UiColors.primary.withValues(alpha: 0.1)
        : const Color(0xFFFEE2E2);

    return Material(
      color: bg,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}
