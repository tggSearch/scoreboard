import 'package:flutter/material.dart';
import 'app_score_display.dart';
import 'ui_tokens.dart';

class AppTeamCard extends StatelessWidget {
  final String teamName;
  final int score;
  final Color? teamColor;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final List<int>? incrementValues;
  final bool compact;

  const AppTeamCard({
    super.key,
    required this.teamName,
    required this.score,
    this.teamColor,
    this.onIncrement,
    this.onDecrement,
    this.incrementValues,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = teamColor ?? Theme.of(context).colorScheme.primary;

    return Container(
      padding: EdgeInsets.all(compact ? UiSpacing.md : UiSpacing.lg),
      decoration: BoxDecoration(
        color: UiColors.card,
        borderRadius: BorderRadius.circular(UiRadius.lg),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            teamName,
            style: TextStyle(
              fontSize: compact ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: accent,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: compact ? 8 : 12),
          AppScoreDisplay(
            score: score.toString(),
            fontSize: compact ? 36 : 48,
            color: UiColors.textPrimary,
          ),
          if (onIncrement != null || onDecrement != null) ...[
            SizedBox(height: compact ? 8 : 12),
            _buildControls(context, accent),
          ],
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context, Color accent) {
    if (incrementValues != null && incrementValues!.isNotEmpty) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: incrementValues!.map((value) {
          return _ScoreButton(
            label: '+$value',
            color: accent,
            onPressed: onIncrement,
          );
        }).toList(),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (onDecrement != null)
          _ScoreButton(
            label: '-1',
            color: UiColors.textSecondary,
            outlined: true,
            onPressed: onDecrement,
          ),
        if (onDecrement != null && onIncrement != null)
          const SizedBox(width: 12),
        if (onIncrement != null)
          _ScoreButton(
            label: '+1',
            color: accent,
            onPressed: onIncrement,
          ),
      ],
    );
  }
}

class _ScoreButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onPressed;
  final bool outlined;

  const _ScoreButton({
    required this.label,
    required this.color,
    this.onPressed,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: outlined ? Colors.transparent : color,
      borderRadius: BorderRadius.circular(UiRadius.md),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(UiRadius.md),
        child: Container(
          constraints: const BoxConstraints(minWidth: 52, minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(UiRadius.md),
            border: outlined ? Border.all(color: UiColors.border) : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: outlined ? UiColors.textPrimary : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
