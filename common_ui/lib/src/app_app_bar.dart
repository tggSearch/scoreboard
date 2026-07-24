import 'package:flutter/material.dart';
import 'ui_tokens.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final String? titleText;
  final List<Widget>? actions;
  final Widget? leading;
  final bool roundedBottom;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottom;

  const AppAppBar({
    super.key,
    this.title,
    this.titleText,
    this.actions,
    this.leading,
    this.roundedBottom = false,
    this.backgroundColor,
    this.bottom,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    final primary = backgroundColor ?? Theme.of(context).colorScheme.primary;

    return AppBar(
      title: title ??
          (titleText != null
              ? Text(titleText!)
              : null),
      actions: actions,
      leading: leading,
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      bottom: bottom,
      shape: roundedBottom
          ? const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(UiRadius.xl),
              ),
            )
          : null,
    );
  }
}
