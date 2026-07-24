import 'package:flutter/material.dart';
import 'ui_tokens.dart';

class AppSurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double borderRadius;
  final bool showShadow;

  const AppSurfaceCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius = UiRadius.lg,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(UiSpacing.xl),
      decoration: BoxDecoration(
        color: color ?? UiColors.card,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}
