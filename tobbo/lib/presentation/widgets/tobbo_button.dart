import 'package:flutter/material.dart';
import 'package:Tobbo/core/constants/app_radii.dart';
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
