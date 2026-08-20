import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:Tobbo/core/constants/app_colors.dart';
import 'package:Tobbo/core/constants/app_radii.dart';
import 'package:Tobbo/core/constants/app_spacing.dart';
import 'package:Tobbo/core/router/app_routes.dart';
import 'package:Tobbo/core/theme/tobbo_palette.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      body: navigationShell,
      floatingActionButton: _AskFab(onPressed: () => context.push(AppRoutes.ask)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: palette.surface,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.huge),
        height: 68,
        child: Row(
          children: [
            _NavItem(
              icon: LucideIcons.house,
              label: 'Home',
              selected: navigationShell.currentIndex == 0,
              onTap: () => _onTap(0),
            ),
            const Spacer(),
            _NavItem(
              icon: LucideIcons.settings,
              label: 'Settings',
              selected: navigationShell.currentIndex == 1,
              onTap: () => _onTap(1),
            ),
          ],
        ),
      ),
    );
  }
}

class _AskFab extends StatelessWidget {
  const _AskFab({required this.onPressed});

  final VoidCallback onPressed;

  static const double _size = 72;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SizedBox(
      width: _size,
      height: _size,
      child: Material(
        color: Colors.transparent,
        elevation: 6,
        shadowColor: palette.deepBrand.withValues(alpha: 0.4),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Ink(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.deepBrand, AppColors.accent],
              ),
            ),
            child: const Icon(LucideIcons.plus, size: 32, color: AppColors.lightSurface),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = selected ? palette.primary : palette.mutedText;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.small),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
