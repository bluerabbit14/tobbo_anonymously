import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Tobbo/core/constants/app_colors.dart';

TextTheme buildTobboTextTheme({
  required Color primary,
  required Color secondary,
  required Color muted,
}) {
  final heading = GoogleFonts.spaceGrotesk(
    color: primary,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
  );
  final body = GoogleFonts.inter(color: primary, fontWeight: FontWeight.w400);

  return TextTheme(
    displayLarge: heading.copyWith(fontSize: 44, height: 1.05, fontWeight: FontWeight.w700),
    displayMedium: heading.copyWith(fontSize: 36, height: 1.1, fontWeight: FontWeight.w700),
    displaySmall: heading.copyWith(fontSize: 28, height: 1.15, fontWeight: FontWeight.w700),
    headlineLarge: heading.copyWith(fontSize: 24, height: 1.2),
    headlineMedium: heading.copyWith(fontSize: 20, height: 1.25),
    headlineSmall: heading.copyWith(fontSize: 18, height: 1.3),
    titleLarge: heading.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
    titleMedium: heading.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
    titleSmall: heading.copyWith(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1.2),
    bodyLarge: body.copyWith(fontSize: 16, height: 1.45, color: secondary),
    bodyMedium: body.copyWith(fontSize: 14, height: 1.45, color: secondary),
    bodySmall: body.copyWith(fontSize: 12, height: 1.4, color: muted),
    labelLarge: body.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
    labelMedium: body.copyWith(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.4, color: muted),
    labelSmall: body.copyWith(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 1.6, color: muted),
  );
}

ThemeData buildLightTheme() {
  final textTheme = buildTobboTextTheme(
    primary: AppColors.lightPrimaryText,
    secondary: AppColors.lightSecondaryText,
    muted: AppColors.lightMutedText,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.lightSurface,
      secondary: AppColors.accent,
      onSecondary: AppColors.deepBrand,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightPrimaryText,
      error: AppColors.lightError,
      onError: AppColors.lightSurface,
      outline: AppColors.lightBorder,
    ),
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.lightBackground,
      foregroundColor: AppColors.lightPrimaryText,
      titleTextStyle: textTheme.titleMedium,
    ),
    dividerColor: AppColors.lightBorder,
    cardColor: AppColors.lightSurface,
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.deepBrand,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: AppColors.lightSurface),
    ),
  );
}

ThemeData buildDarkTheme() {
  final textTheme = buildTobboTextTheme(
    primary: AppColors.darkPrimaryText,
    secondary: AppColors.darkSecondaryText,
    muted: AppColors.darkMutedText,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: AppColors.darkBackground,
      secondary: AppColors.primary,
      onSecondary: AppColors.darkPrimaryText,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkPrimaryText,
      error: AppColors.darkError,
      onError: AppColors.darkBackground,
      outline: AppColors.darkBorder,
    ),
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.darkPrimaryText,
      titleTextStyle: textTheme.titleMedium,
    ),
    dividerColor: AppColors.darkBorder,
    cardColor: AppColors.darkSurface,
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.darkSecondarySurface,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: AppColors.darkPrimaryText),
    ),
  );
}
