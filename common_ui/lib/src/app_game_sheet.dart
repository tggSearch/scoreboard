import 'package:flutter/material.dart';
import 'ui_tokens.dart';
import 'keyboard_dismiss.dart';

/// Green header + white rounded sheet layout for game pages.
class AppGameSheet extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomBar;
  final Color headerColor;

  const AppGameSheet({
    super.key,
    this.appBar,
    required this.body,
    this.bottomBar,
    this.headerColor = UiColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: headerColor,
      appBar: appBar,
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: UiColors.card,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(UiRadius.xl),
                  topRight: Radius.circular(UiRadius.xl),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: KeyboardDismissOnTap(child: body),
            ),
          ),
          if (bottomBar != null)
            Container(
              color: UiColors.card,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SafeArea(top: false, child: bottomBar!),
            ),
        ],
      ),
    );
  }
}

/// Section card used inside game pages.
class AppSectionCard extends StatelessWidget {
  final String? title;
  final Widget? titleTrailing;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const AppSectionCard({
    super.key,
    this.title,
    this.titleTrailing,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: UiColors.surfaceVariant,
        borderRadius: BorderRadius.circular(UiRadius.lg),
        border: Border.all(color: UiColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title!,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: UiColors.textPrimary,
                      ),
                    ),
                  ),
                  if (titleTrailing != null) titleTrailing!,
                ],
              ),
            ),
          Padding(
            padding: padding ?? const EdgeInsets.all(12),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Player row card inside game pages.
class AppPlayerCard extends StatelessWidget {
  final Widget leading;
  final Widget content;
  final List<Widget>? actions;

  const AppPlayerCard({
    super.key,
    required this.leading,
    required this.content,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: UiColors.card,
        borderRadius: BorderRadius.circular(UiRadius.md),
        border: Border.all(color: UiColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          leading,
          const SizedBox(width: 12),
          Expanded(child: content),
          if (actions != null) ...[
            const SizedBox(width: 8),
            Row(mainAxisSize: MainAxisSize.min, children: actions!),
          ],
        ],
      ),
    );
  }
}
