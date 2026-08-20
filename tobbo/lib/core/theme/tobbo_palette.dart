import 'package:flutter/material.dart';
import 'package:Tobbo/core/constants/app_colors.dart';

class TobboPalette {
  const TobboPalette({
    required this.background,
    required this.surface,
    required this.secondarySurface,
    required this.primary,
    required this.deepBrand,
    required this.accent,
    required this.primaryText,
    required this.secondaryText,
    required this.mutedText,
    required this.border,
  });

  final Color background;
  final Color surface;
  final Color secondarySurface;
  final Color primary;
  final Color deepBrand;
  final Color accent;
  final Color primaryText;
  final Color secondaryText;
  final Color mutedText;
  final Color border;

  static const light = TobboPalette(
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    secondarySurface: AppColors.lightSecondarySurface,
    primary: AppColors.primary,
    deepBrand: AppColors.deepBrand,
    accent: AppColors.accent,
    primaryText: AppColors.lightPrimaryText,
    secondaryText: AppColors.lightSecondaryText,
    mutedText: AppColors.lightMutedText,
    border: AppColors.lightBorder,
  );

  static const dark = TobboPalette(
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    secondarySurface: AppColors.darkSecondarySurface,
    primary: AppColors.accent,
    deepBrand: AppColors.deepBrand,
    accent: AppColors.accent,
    primaryText: AppColors.darkPrimaryText,
    secondaryText: AppColors.darkSecondaryText,
    mutedText: AppColors.darkMutedText,
    border: AppColors.darkBorder,
  );
}

extension PaletteX on BuildContext {
  TobboPalette get palette {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark ? TobboPalette.dark : TobboPalette.light;
  }
}
