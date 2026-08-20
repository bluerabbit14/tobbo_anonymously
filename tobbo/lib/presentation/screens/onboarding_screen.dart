import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Tobbo/core/constants/app_colors.dart';
import 'package:Tobbo/core/constants/app_spacing.dart';
import 'package:Tobbo/core/router/app_routes.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const cream = AppColors.lightBackground;
    return Scaffold(
      backgroundColor: AppColors.deepBrand,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.pagePadding, AppSpacing.xl, AppSpacing.pagePadding, AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tobbo',
                style: GoogleFonts.spaceGrotesk(
                  color: cream,
                  fontSize: 18,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                'Ask anything.\nGet honest answers.',
                style: GoogleFonts.spaceGrotesk(
                  color: cream,
                  fontSize: 42,
                  height: 1.08,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Get real opinions from real people — without revealing who you are.',
                style: GoogleFonts.inter(
                  color: cream.withValues(alpha: 0.82),
                  fontSize: 16,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Ask. Vote. Decide.',
                style: GoogleFonts.spaceGrotesk(
                  color: AppColors.accent,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () => context.go(AppRoutes.home),
                  style: FilledButton.styleFrom(
                    backgroundColor: cream,
                    foregroundColor: AppColors.deepBrand,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Get Started',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: Text(
                  'Your identity stays private.',
                  style: GoogleFonts.inter(color: cream.withValues(alpha: 0.7), fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
