import 'package:flutter/material.dart';
import 'package:Tobbo/core/constants/app_radii.dart';
import 'package:Tobbo/core/constants/app_spacing.dart';
import 'package:Tobbo/core/theme/tobbo_palette.dart';

class TobboButton extends StatelessWidget {
  const TobboButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.secondary = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    if (secondary) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: palette.border),
            foregroundColor: palette.primaryText,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.input)),
          ),
          child: Text(label),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: palette.primary,
          disabledBackgroundColor: palette.border,
          foregroundColor: palette.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.input)),
        ),
        child: Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: palette.surface)),
      ),
    );
  }
}

class RadiusChips extends StatelessWidget {
  const RadiusChips({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    const options = [1.0, 5.0, 10.0];
    final palette = context.palette;
    return Row(
      children: [
        for (final option in options) ...[
          GestureDetector(
            onTap: () => onChanged(option),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: value == option ? palette.primary : palette.surface,
                borderRadius: BorderRadius.circular(AppRadii.pill),
                border: Border.all(color: value == option ? palette.primary : palette.border),
              ),
              child: Text(
                '${option.round()} km',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: value == option ? palette.surface : palette.primaryText,
                    ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ],
    );
  }
}
