import 'package:flutter/material.dart';

/// Unified keyboard dismiss helpers for the app.
abstract final class KeyboardDismiss {
  /// Dismiss the currently focused text field / keyboard.
  static void dismiss() {
    final focus = FocusManager.instance.primaryFocus;
    if (focus != null && focus.hasFocus) {
      focus.unfocus();
    }
  }
}

/// Wrap content so tapping empty areas dismisses the keyboard.
class KeyboardDismissOnTap extends StatelessWidget {
  final Widget child;

  const KeyboardDismissOnTap({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: KeyboardDismiss.dismiss,
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}

/// Scroll view that also dismisses keyboard when dragging.
class KeyboardDismissScrollView extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;

  const KeyboardDismissScrollView({
    super.key,
    required this.child,
    this.padding,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
      child: SingleChildScrollView(
        padding: padding,
        physics: physics,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: child,
      ),
    );
  }
}

/// List view that dismisses keyboard when dragging.
class KeyboardDismissListView extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const KeyboardDismissListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
      child: ListView.builder(
        padding: padding,
        physics: physics,
        shrinkWrap: shrinkWrap,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      ),
    );
  }
}
