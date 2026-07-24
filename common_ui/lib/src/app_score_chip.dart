import 'package:flutter/material.dart';
import 'ui_tokens.dart';

class AppScoreChip extends StatefulWidget {
  final Widget icon;
  final String label;
  final Color? accentColor;
  final VoidCallback onTap;

  const AppScoreChip({
    super.key,
    required this.icon,
    required this.label,
    this.accentColor,
    required this.onTap,
  });

  @override
  State<AppScoreChip> createState() => _AppScoreChipState();
}

class _AppScoreChipState extends State<AppScoreChip> {
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: UiColors.surfaceVariant,
            borderRadius: BorderRadius.circular(UiRadius.sm),
            border: Border.all(color: UiColors.border),
          ),
          child: Row(
            children: [
              SizedBox(width: 20, height: 20, child: widget.icon),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: UiColors.textPrimary,
                  ),
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
