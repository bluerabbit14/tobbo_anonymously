import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Tobbo/core/constants/app_spacing.dart';
import 'package:Tobbo/core/router/app_routes.dart';
import 'package:Tobbo/domain/entities/poll.dart';
import 'package:Tobbo/presentation/app_scope.dart';
import 'package:Tobbo/presentation/widgets/empty_state.dart';
import 'package:Tobbo/presentation/widgets/poll_controls.dart';
import 'package:Tobbo/presentation/widgets/tobbo_button.dart';
import 'package:Tobbo/presentation/widgets/tobbo_loader.dart';

class PollDetailScreen extends StatefulWidget {
  const PollDetailScreen({super.key, required this.code, this.shared = false});

  final String code;
  final bool shared;

  @override
  State<PollDetailScreen> createState() => _PollDetailScreenState();
}

class _PollDetailScreenState extends State<PollDetailScreen> {
  String? _selectedId;
  String? _error;
  bool _voting = false;

  Future<void> _vote(Poll poll) async {
    if (_selectedId == null) return;
    setState(() {
      _voting = true;
      _error = null;
    });
    try {
      await context.pollStore.vote(publicCode: poll.publicCode, optionId: _selectedId!);
      if (!mounted) return;
      context.pushReplacement(AppRoutes.results(poll.publicCode));
    } catch (error) {
      setState(() => _error = error.toString().replaceFirst('StateError: ', ''));
    } finally {
      if (mounted) setState(() => _voting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: context.pollStore,
      builder: (context, _) {
        return FutureBuilder<Poll>(
          future: context.pollStore.getPoll(widget.code),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Scaffold(
                body: SafeArea(
                  child: EmptyState(
                    title: 'Something went wrong.',
                    message: snapshot.error.toString(),
                    actionLabel: 'Try again',
                    onAction: () => setState(() {}),
                  ),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Scaffold(body: Center(child: TobboLoader()));
            }
            final poll = snapshot.data!;
            return Scaffold(
              body: Stack(
                children: [
                  SafeArea(
                    child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePadding,
                    AppSpacing.sm,
                    AppSpacing.pagePadding,
                    AppSpacing.xxl,
                  ),
                  children: [
                    ScreenHeader(
                      title: widget.shared ? 'Shared question' : 'Anonymous question',
                      onBack: widget.shared ? null : () => context.pop(),
                    ),
                    if (widget.shared)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Text('Tobbo', style: Theme.of(context).textTheme.titleLarge),
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(poll.question, style: Theme.of(context).textTheme.displaySmall),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      poll.isClosed
                          ? 'This question has closed.'
                          : [
                              '${poll.voteCount} people have voted',
                              if (poll.distanceKm != null) '${poll.distanceKm!.toStringAsFixed(1)} km away',
                            ].join('  '),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (poll.isClosed) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text('Voting is no longer available.', style: Theme.of(context).textTheme.bodySmall),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    if (poll.hasVoted || poll.isClosed) ...[
                      if (poll.hasVoted) ...[
                        Text('YOU’VE ALREADY VOTED', style: Theme.of(context).textTheme.labelMedium),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'You voted for:\n${poll.votedOptionText}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                      for (final option in poll.options)
                        ResultBar(
                          option: option,
                          totalVotes: poll.voteCount,
                          marked: option.id == poll.votedOptionId,
                        ),
                      const SizedBox(height: AppSpacing.md),
                      Text('Your vote is anonymous.', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: AppSpacing.xl),
                      TobboButton(
                        label: 'View full results',
                        onPressed: () => context.push(AppRoutes.results(poll.publicCode)),
                      ),
                    ] else ...[
                      for (var i = 0; i < poll.options.length; i++)
                        OptionTile(
                          option: poll.options[i],
                          index: i,
                          selected: _selectedId == poll.options[i].id,
                          onTap: () => setState(() => _selectedId = poll.options[i].id),
                        ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        widget.shared ? 'Vote anonymously. No account required.' : 'Your vote is anonymous.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      TobboButton(
                        label: _voting ? 'Voting…' : 'Vote',
                        onPressed: _selectedId == null || _voting ? null : () => _vote(poll),
                      ),
                      if (widget.shared) ...[
                        const SizedBox(height: AppSpacing.sm),
                        TobboButton(
                          label: 'Explore Tobbo',
                          secondary: true,
                          onPressed: () => context.go(AppRoutes.home),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
                  if (_voting) const TobboLoadingOverlay(),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
