import 'package:flutter/material.dart';

/// Official Tobbo palette. Never use pure black.
abstract final class AppColors {
  AppColors._();

  static const Color deepBrand = Color(0xFF464B71);
  static const Color primary = Color(0xFF118AB2);
  static const Color accent = Color(0xFF7CD5C7);

  static const Color lightBackground = Color(0xFFF2F2ED);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSecondarySurface = Color(0xFFF7F7F3);
  static const Color lightPrimaryText = Color(0xFF20232A);
  static const Color lightSecondaryText = Color(0xFF5F6268);
  static const Color lightMutedText = Color(0xFF85898C);
  static const Color lightBorder = Color(0xFFDDE1DD);
  static const Color lightSuccess = Color(0xFF2F8F72);
  static const Color lightWarning = Color(0xFFD99A3D);
  static const Color lightError = Color(0xFFC75C5C);

  static const Color darkBackground = Color(0xFF15191B);
  static const Color darkSurface = Color(0xFF1E2426);
  static const Color darkSecondarySurface = Color(0xFF273033);
  static const Color darkPrimaryText = Color(0xFFF2F2ED);
  static const Color darkSecondaryText = Color(0xFFB8C1C1);
  static const Color darkMutedText = Color(0xFF7F898B);
  static const Color darkBorder = Color(0xFF354043);
  static const Color darkSuccess = Color(0xFF38B58D);
  static const Color darkWarning = Color(0xFFE0AA55);
  static const Color darkError = Color(0xFFE06B6B);
}
