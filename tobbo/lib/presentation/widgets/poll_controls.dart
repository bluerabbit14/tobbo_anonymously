import 'package:flutter/material.dart';
import 'package:Tobbo/core/constants/app_radii.dart';
import 'package:Tobbo/core/constants/app_spacing.dart';
import 'package:Tobbo/core/theme/tobbo_palette.dart';
import 'package:Tobbo/domain/entities/poll_option.dart';

class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.option,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  final PollOption option;
  final int index;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: selected ? palette.primary.withValues(alpha: 0.08) : palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          side: BorderSide(color: selected ? palette.primary : palette.border, width: selected ? 1.4 : 1),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.card),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 18),
            child: Row(
              children: [
                Text(
                  (index + 1).toString().padLeft(2, '0'),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: selected ? palette.primary : palette.mutedText,
                      ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(option.text, style: Theme.of(context).textTheme.titleMedium)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ResultBar extends StatelessWidget {
  const ResultBar({
    super.key,
    required this.option,
    required this.totalVotes,
    this.marked = false,
  });

  final PollOption option;
  final int totalVotes;
  final bool marked;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final percent = option.percentageOf(totalVotes);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  marked ? '${option.text}  Your vote' : option.text,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                '${percent.round()}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: palette.primary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: percent / 100),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  minHeight: 8,
                  value: value,
                  backgroundColor: palette.secondarySurface,
                  color: palette.primary,
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          Text('${option.voteCount} votes', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
