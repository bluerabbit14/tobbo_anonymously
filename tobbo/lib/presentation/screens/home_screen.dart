import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:Tobbo/core/constants/app_spacing.dart';
import 'package:Tobbo/core/router/app_routes.dart';
import 'package:Tobbo/core/theme/tobbo_palette.dart';
import 'package:Tobbo/domain/entities/poll.dart';
import 'package:Tobbo/presentation/app_scope.dart';
import 'package:Tobbo/presentation/widgets/empty_state.dart';
import 'package:Tobbo/presentation/widgets/poll_card.dart';
import 'package:Tobbo/presentation/widgets/tobbo_button.dart';
import 'package:Tobbo/presentation/widgets/tobbo_loader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning.';
    if (hour < 17) return 'Good afternoon.';
    return 'Good evening.';
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AnimatedBuilder(
      animation: context.repos.listenable,
      builder: (context, _) {
        final settings = context.settingsStore.current;
        final future = settings.nearbyEnabled
            ? context.pollStore.getNearbyPolls(radiusKm: settings.radiusKm)
            : Future<List<Poll>>.value(const []);
        return FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            final items = snapshot.data ?? [];
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
                    Row(
                      children: [
                        Text('Tobbo', style: Theme.of(context).textTheme.titleLarge),
                        const Spacer(),
                        Icon(LucideIcons.map_pin, size: 16, color: palette.mutedText),
                        const SizedBox(width: 6),
                        Text('Near you', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(_greeting(), style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'What do you need\nan opinion on?',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => context.push(AppRoutes.ask),
                        child: Text(
                          'Ask Tobbo',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: palette.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    RadiusChips(
                      value: settings.radiusKm,
                      onChanged: context.settingsStore.setRadiusKm,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Row(
                      children: [
                        Text('Nearby questions', style: Theme.of(context).textTheme.titleSmall),
                        const Spacer(),
                        Text(
                          '${items.length} ${items.length == 1 ? 'question' : 'questions'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (snapshot.connectionState != ConnectionState.done)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: TobboLoader()),
                      )
                    else if (snapshot.hasError)
                      EmptyState(
                        title: "Couldn't load nearby questions.",
                        message: snapshot.error.toString(),
                        actionLabel: 'Try again',
                        onAction: () => setState(() {}),
                      )
                    else if (items.isEmpty)
                      EmptyState(
                        title: 'Nothing nearby yet.',
                        message: 'Be the first to ask something.',
                        actionLabel: 'Ask Tobbo',
                        onAction: () => context.push(AppRoutes.ask),
                      )
                    else
                      for (final poll in items) ...[
                        PollCard(
                          poll: poll,
                          onTap: () => context.push(AppRoutes.poll(poll.publicCode)),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
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
