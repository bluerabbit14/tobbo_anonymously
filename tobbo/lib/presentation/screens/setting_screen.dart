import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:Tobbo/core/constants/app_colors.dart';
import 'package:Tobbo/core/constants/app_radii.dart';
import 'package:Tobbo/core/constants/app_spacing.dart';
import 'package:Tobbo/core/router/app_routes.dart';
import 'package:Tobbo/core/theme/tobbo_palette.dart';
import 'package:Tobbo/core/utils/app_version.dart';
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
                    const SizedBox(height: AppSpacing.sm),
                    _SettingsCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text('Appearance', style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: AppSpacing.sm),
                    _SettingsCard(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      child: Row(
                        children: [
                          for (final entry in {
                            ThemeMode.system: 'System',
                            ThemeMode.light: 'Light',
                            ThemeMode.dark: 'Dark',
                          }.entries) ...[
                            Expanded(
                              child: _ChoiceChip(
                                label: entry.value,
                                selected: settings.themeMode == entry.key,
                                onTap: () => context.settingsStore.setThemeMode(entry.key),
                              ),
                            ),
                            if (entry.key != ThemeMode.dark) const SizedBox(width: AppSpacing.xxs),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text('Your activity', style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: AppSpacing.sm),
                    _SettingsCard(
                      padding: EdgeInsets.zero,
                      child: ListTile(
                        title: const Text('My questions & votes'),
                        trailing: Icon(LucideIcons.chevron_right, color: palette.mutedText),
                        onTap: () => context.push(AppRoutes.activity),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text('Discovery', style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: AppSpacing.sm),
                    _SettingsCard(
                      child: Column(
                        children: [
                          _SettingsSwitchTile(
                            title: 'Nearby questions',
                            subtitle: 'Show questions from people around you',
                            value: settings.nearbyEnabled,
                            onChanged: context.settingsStore.setNearbyEnabled,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _RadiusSlider(
                            value: settings.radiusKm,
                            onChanged: context.settingsStore.setRadiusKm,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _SettingsSwitchTile(
                            title: 'Location access',
                            subtitle: 'Used to find questions near you',
                            value: settings.locationAccess,
                            onChanged: context.settingsStore.setLocationAccess,
                          ),
                          _SettingsSwitchTile(
                            title: 'Notifications',
                            subtitle: 'Get notified when your question gets votes',
                            value: settings.notificationsEnabled,
                            onChanged: context.settingsStore.setNotificationsEnabled,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text('Data', style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: AppSpacing.sm),
                    _SettingsCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Clearing this device starts a new anonymous identity. Previous questions and votes stay on the server but won’t be linked here.',
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
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    FutureBuilder<String>(
                      future: appVersionLabel(),
                      builder: (context, snapshot) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              snapshot.data ?? 'Tobbo',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: palette.mutedText),
                            ),
                          ],
                        );
                      },
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

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.lg),
        child: child,
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  static const double _switchScale = 0.75;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Transform.scale(
        scale: _switchScale,
        alignment: Alignment.centerRight,
        child: Switch(
          value: value,
          onChanged: onChanged,
        ),
      ),
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

class _RadiusSlider extends StatefulWidget {
  const _RadiusSlider({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  State<_RadiusSlider> createState() => _RadiusSliderState();
}

class _RadiusSliderState extends State<_RadiusSlider> {
  static const double _minKm = 1;
  static const double _maxKm = 10;

  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value.clamp(_minKm, _maxKm);
  }

  @override
  void didUpdateWidget(covariant _RadiusSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _value = widget.value.clamp(_minKm, _maxKm);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Search radius', style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            Text(
              '${_value.round()} km',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: palette.primary),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            activeTrackColor: palette.primary,
            inactiveTrackColor: palette.border,
            thumbColor: palette.primary,
            overlayColor: palette.primary.withValues(alpha: 0.12),
            valueIndicatorColor: palette.deepBrand,
            valueIndicatorTextStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.lightSurface,
                ),
          ),
          child: Slider(
            min: _minKm,
            max: _maxKm,
            divisions: (_maxKm - _minKm).round(),
            value: _value,
            label: '${_value.round()} km',
            onChanged: (value) => setState(() => _value = value),
            onChangeEnd: (value) => widget.onChanged(value.roundToDouble()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Text('1 km', style: Theme.of(context).textTheme.bodySmall),
              const Spacer(),
              Text('10 km', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
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
        width: double.infinity,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? palette.primary : palette.secondarySurface,
          borderRadius: BorderRadius.circular(AppRadii.small),
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
