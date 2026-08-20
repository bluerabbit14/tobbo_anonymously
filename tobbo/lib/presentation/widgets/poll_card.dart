import 'package:flutter/material.dart';
import 'package:Tobbo/core/constants/app_radii.dart';
import 'package:Tobbo/core/constants/app_spacing.dart';
import 'package:Tobbo/core/theme/tobbo_palette.dart';
import 'package:Tobbo/domain/entities/poll.dart';

class PollCard extends StatelessWidget {
  const PollCard({super.key, required this.poll, required this.onTap});

  final Poll poll;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final meta = [
      '${poll.voteCount} votes',
      if (poll.distanceKm != null) '${poll.distanceKm!.toStringAsFixed(1)} km',
      if (poll.isClosed) 'closed',
    ].join(' · ');

    return Material(
      color: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: BorderSide(color: palette.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Anonymous question',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(poll.question, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              for (final option in poll.options)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '·  ${option.text}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
              Text(meta, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
