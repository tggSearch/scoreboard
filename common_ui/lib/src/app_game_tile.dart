import 'package:flutter/material.dart';
import 'ui_tokens.dart';

class AppGameTile extends StatefulWidget {
  final Widget icon;
  final String label;
  final Color accentColor;
  final VoidCallback onTap;
  final double size;
  final bool lightText;

  const AppGameTile({
    super.key,
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.onTap,
    this.size = 100,
    this.lightText = false,
  });

  @override
  State<AppGameTile> createState() => _AppGameTileState();
}

class _AppGameTileState extends State<AppGameTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.accentColor.withValues(alpha: widget.lightText ? 0.2 : 0.12),
                widget.accentColor.withValues(alpha: widget.lightText ? 0.1 : 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(UiRadius.lg),
            border: Border.all(
              color: widget.accentColor.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(UiSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: widget.lightText ? 0.2 : 0.5),
                  borderRadius: BorderRadius.circular(UiRadius.md),
                ),
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: widget.icon,
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: widget.lightText ? Colors.white : UiColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
