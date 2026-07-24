import 'package:flutter/material.dart';
import 'ui_tokens.dart';

class AppScoreDisplay extends StatelessWidget {
  final String score;
  final double fontSize;
  final Color? color;
  final TextAlign textAlign;

  const AppScoreDisplay({
    super.key,
    required this.score,
    this.fontSize = 48,
    this.color,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: Text(
        score,
        key: ValueKey(score),
        textAlign: textAlign,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
          color: color ?? UiColors.textPrimary,
          height: 1.1,
        ),
      ),
    );
  }
}
