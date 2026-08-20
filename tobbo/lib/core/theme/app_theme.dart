import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Tobbo/core/constants/app_colors.dart';
import 'package:Tobbo/core/constants/app_radii.dart';

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

SystemUiOverlayStyle tobboOverlayStyle(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    systemNavigationBarColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
    systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    systemNavigationBarDividerColor: Colors.transparent,
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
    iconTheme: const IconThemeData(color: AppColors.lightPrimaryText, size: 22),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: AppColors.lightPrimaryText),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.lightBackground,
      foregroundColor: AppColors.lightPrimaryText,
      titleTextStyle: textTheme.titleMedium,
      systemOverlayStyle: tobboOverlayStyle(Brightness.light),
    ),
    dividerColor: AppColors.lightBorder,
    cardColor: AppColors.lightSurface,
    cardTheme: CardThemeData(
      color: AppColors.lightSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 2,
      shadowColor: AppColors.deepBrand.withValues(alpha: 0.10),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
    ),
    inputDecorationTheme: _inputTheme(
      fill: AppColors.lightSurface,
      border: AppColors.lightBorder,
      focused: AppColors.primary,
      hint: AppColors.lightMutedText,
      icon: AppColors.lightMutedText,
      textTheme: textTheme,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.lightSurface,
      surfaceTintColor: Colors.transparent,
      dragHandleColor: AppColors.lightBorder,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.large)),
        side: BorderSide(color: AppColors.lightBorder),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.lightMutedText,
      textColor: AppColors.lightPrimaryText,
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.lightPrimaryText,
      unselectedLabelColor: AppColors.lightMutedText,
      indicatorColor: AppColors.primary,
      dividerColor: AppColors.lightBorder,
    ),
    bottomAppBarTheme: const BottomAppBarThemeData(
      color: AppColors.lightSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    sliderTheme: SliderThemeData(
      trackHeight: 4,
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.lightBorder,
      thumbColor: AppColors.primary,
      overlayColor: AppColors.primary.withValues(alpha: 0.12),
      valueIndicatorColor: AppColors.deepBrand,
      valueIndicatorTextStyle: textTheme.labelLarge?.copyWith(color: AppColors.lightSurface),
    ),
    switchTheme: _switchTheme(
      selectedTrack: AppColors.primary,
      unselectedTrack: AppColors.lightBorder,
      selectedThumb: AppColors.lightSurface,
      unselectedThumb: AppColors.lightMutedText,
    ),
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
    iconTheme: const IconThemeData(color: AppColors.darkPrimaryText, size: 22),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: AppColors.darkPrimaryText),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.darkPrimaryText,
      titleTextStyle: textTheme.titleMedium,
      systemOverlayStyle: tobboOverlayStyle(Brightness.dark),
    ),
    dividerColor: AppColors.darkBorder,
    cardColor: AppColors.darkSurface,
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.45),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
    ),
    inputDecorationTheme: _inputTheme(
      fill: AppColors.darkSurface,
      border: AppColors.darkBorder,
      focused: AppColors.accent,
      hint: AppColors.darkMutedText,
      icon: AppColors.darkMutedText,
      textTheme: textTheme,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.darkSurface,
      surfaceTintColor: Colors.transparent,
      dragHandleColor: AppColors.darkBorder,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.large)),
        side: BorderSide(color: AppColors.darkBorder),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.darkMutedText,
      textColor: AppColors.darkPrimaryText,
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.darkPrimaryText,
      unselectedLabelColor: AppColors.darkMutedText,
      indicatorColor: AppColors.accent,
      dividerColor: AppColors.darkBorder,
    ),
    bottomAppBarTheme: const BottomAppBarThemeData(
      color: AppColors.darkSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    sliderTheme: SliderThemeData(
      trackHeight: 4,
      activeTrackColor: AppColors.accent,
      inactiveTrackColor: AppColors.darkBorder,
      thumbColor: AppColors.accent,
      overlayColor: AppColors.accent.withValues(alpha: 0.12),
      valueIndicatorColor: AppColors.deepBrand,
      valueIndicatorTextStyle: textTheme.labelLarge?.copyWith(color: AppColors.lightSurface),
    ),
    switchTheme: _switchTheme(
      selectedTrack: AppColors.accent,
      unselectedTrack: AppColors.darkBorder,
      selectedThumb: AppColors.deepBrand,
      unselectedThumb: AppColors.darkMutedText,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.darkSecondarySurface,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: AppColors.darkPrimaryText),
    ),
  );
}

InputDecorationTheme _inputTheme({
  required Color fill,
  required Color border,
  required Color focused,
  required Color hint,
  required Color icon,
  required TextTheme textTheme,
}) {
  final radius = BorderRadius.circular(AppRadii.input);
  return InputDecorationTheme(
    filled: true,
    fillColor: fill,
    hintStyle: textTheme.bodyMedium?.copyWith(color: hint),
    suffixIconColor: icon,
    prefixIconColor: icon,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: border)),
    enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: border)),
    focusedBorder: OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: focused, width: 1.4),
    ),
  );
}

SwitchThemeData _switchTheme({
  required Color selectedTrack,
  required Color unselectedTrack,
  required Color selectedThumb,
  required Color unselectedThumb,
}) {
  return SwitchThemeData(
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    thumbColor: WidgetStateProperty.resolveWith((states) {
      return states.contains(WidgetState.selected) ? selectedThumb : unselectedThumb;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      return states.contains(WidgetState.selected) ? selectedTrack : unselectedTrack;
    }),
    trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
  );
}
