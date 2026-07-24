import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders an in-app game/score SVG icon with optional tint.
class GameIcon extends StatelessWidget {
  final String assetPath;
  final double size;
  final Color? color;

  const GameIcon({
    super.key,
    required this.assetPath,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? Theme.of(context).colorScheme.primary;

    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
    );
  }
}
