import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Tobbo/core/constants/app_colors.dart';
import 'package:Tobbo/core/constants/app_spacing.dart';
import 'package:Tobbo/core/router/app_routes.dart';
import 'package:Tobbo/data/services/permission_service.dart';
import 'package:Tobbo/presentation/app_scope.dart';
import 'package:Tobbo/presentation/widgets/tobbo_loader.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _starting = false;
  String? _error;

  Future<void> _getStarted() async {
    setState(() {
      _starting = true;
      _error = null;
    });
    try {
      final permissions = await PermissionService().requestOnboarding();
      if (!mounted) return;
      context.settingsStore.setLocationAccess(permissions.locationGranted);
      context.settingsStore.setNotificationsEnabled(permissions.notificationsGranted);
      if (!permissions.locationGranted) {
        context.settingsStore.setNearbyEnabled(false);
      }
      await context.sessionStore.ensureSession();
      if (!mounted) return;
      context.go(AppRoutes.home);
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const cream = AppColors.lightBackground;
    return Scaffold(
      backgroundColor: AppColors.deepBrand,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePadding,
                AppSpacing.xl,
                AppSpacing.pagePadding,
                AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/tobbo.png',
                        height: 28,
                        width: 28,
                        filterQuality: FilterQuality.high,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Tobbo'.toUpperCase(),
                        style: GoogleFonts.spaceGrotesk(
                          color: cream,
                          fontSize: 18,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
                  const SizedBox(height: AppSpacing.lg),
                  Divider(
                    color: AppColors.accent,
                    thickness: 1,
                    endIndent: 200,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Ask. Vote. Decide.',
                    style: GoogleFonts.spaceGrotesk(
                      color: AppColors.accent,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (_error != null) ...[
                    Text(
                      _error!,
                      style: GoogleFonts.inter(color: cream, fontSize: 13),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: _starting ? null : _getStarted,
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
          if (_starting) const TobboLoadingOverlay(color: cream),
        ],
      ),
    );
  }
}
