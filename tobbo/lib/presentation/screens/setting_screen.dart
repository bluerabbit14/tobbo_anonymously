import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Tobbo/core/constants/app_radii.dart';
import 'package:Tobbo/core/constants/app_spacing.dart';
import 'package:Tobbo/core/router/app_routes.dart';
import 'package:Tobbo/core/theme/tobbo_palette.dart';
import 'package:Tobbo/presentation/app_scope.dart';
import 'package:Tobbo/presentation/widgets/tobbo_button.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AnimatedBuilder(
      animation: context.repos.listenable,
      builder: (context, _) {
        final settings = context.settingsStore.current;
        return FutureBuilder(
          future: Future.wait([
            context.pollStore.getMyPolls(),
            context.pollStore.getMyVotes(),
          ]),
          builder: (context, snapshot) {
            final asked = snapshot.data?[0].length ?? 0;
            final voted = snapshot.data?[1].length ?? 0;
            return Scaffold(
              body: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePadding,
                    AppSpacing.md,
                    AppSpacing.pagePadding,
                    120,
                  ),
                  children: [
                    Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: AppSpacing.xxl),
                    Text('Anonymous', style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text('You are Anonymous', style: Theme.of(context).textTheme.displaySmall),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'No name, no photo, no profile. Only your answers travel.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: [
                        _Stat(value: '$asked', label: 'Asked'),
                        const SizedBox(width: AppSpacing.xxl),
                        _Stat(value: '$voted', label: 'Voted'),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text('Appearance', style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        for (final entry in {
                          ThemeMode.system: 'System',
                          ThemeMode.light: 'Light',
                          ThemeMode.dark: 'Dark',
                        }.entries) ...[
                          _ChoiceChip(
                            label: entry.value,
                            selected: settings.themeMode == entry.key,
                            onTap: () => context.settingsStore.setThemeMode(entry.key),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text('Discovery', style: Theme.of(context).textTheme.labelMedium),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Nearby questions'),
                      subtitle: const Text('Show questions from people around you'),
                      value: settings.nearbyEnabled,
                      onChanged: context.settingsStore.setNearbyEnabled,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Search radius', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    RadiusChips(
                      value: settings.radiusKm,
                      onChanged: context.settingsStore.setRadiusKm,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Location access'),
                      subtitle: const Text('Used only to sort questions by distance'),
                      value: settings.locationAccess,
                      onChanged: context.settingsStore.setLocationAccess,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Notifications'),
                      subtitle: const Text('Get notified when your question gets votes'),
                      value: settings.notificationsEnabled,
                      onChanged: context.settingsStore.setNotificationsEnabled,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text('Your activity', style: Theme.of(context).textTheme.labelMedium),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('My questions & votes'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(AppRoutes.activity),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text('Data', style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Everything lives on this device. Clearing removes your questions and votes.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TobboButton(
                      label: 'Clear local data',
                      secondary: true,
                      onPressed: () async {
                        await context.pollStore.clearLocalData();
                        if (!context.mounted) return;
                        context.settingsStore.reset();
                      },
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      'Tobbo · v1.0',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: palette.mutedText),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: Theme.of(context).textTheme.displaySmall),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? palette.primary : palette.surface,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: selected ? palette.primary : palette.border),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected ? palette.surface : palette.primaryText,
              ),
        ),
      ),
    );
  }
}
