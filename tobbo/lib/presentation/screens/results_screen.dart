import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:Tobbo/core/constants/app_spacing.dart';
import 'package:Tobbo/core/router/app_routes.dart';
import 'package:Tobbo/core/theme/tobbo_palette.dart';
import 'package:Tobbo/domain/entities/poll.dart';
import 'package:Tobbo/presentation/app_scope.dart';
import 'package:Tobbo/presentation/widgets/empty_state.dart';
import 'package:Tobbo/presentation/widgets/poll_controls.dart';
import 'package:Tobbo/presentation/widgets/tobbo_button.dart';
import 'package:Tobbo/presentation/widgets/tobbo_loader.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key, required this.code});

  final String code;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {

  String _shareUrl(Poll poll) => 'https://tobboweb.vercel.app/p/${poll.publicCode}';

  Future<void> _share(BuildContext context, Poll poll) async {
    final palette = context.palette;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: palette.surface,
      showDragHandle: true,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Share this question', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(_shareUrl(poll), style: Theme.of(context).textTheme.bodyMedium),
                  ),
                  IconButton(
                    icon: Icon(LucideIcons.copy, color: palette.primaryText),
                    tooltip: 'Copy link',
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: _shareUrl(poll)));
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link copied')),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(LucideIcons.share, color: palette.mutedText),
                title: const Text('More'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  SharePlus.instance.share(
                    ShareParams(text: '${poll.question}\n${_shareUrl(poll)}'),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: context.pollStore,
      builder: (context, _) {
        return FutureBuilder<Poll>(
          future: context.pollStore.getResults(widget.code),
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
              body: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePadding,
                    AppSpacing.sm,
                    AppSpacing.pagePadding,
                    AppSpacing.xxl,
                  ),
                  children: [
                    ScreenHeader(title: 'Results', onBack: () => context.pop()),
                    const SizedBox(height: AppSpacing.xl),
                    Text(poll.question, style: Theme.of(context).textTheme.displaySmall),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '${poll.voteCount} PEOPLE VOTED',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    if (poll.isClosed) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text('This question has closed.', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    for (final option in poll.options)
                      ResultBar(
                        option: option,
                        totalVotes: poll.voteCount,
                        marked: option.id == poll.votedOptionId,
                      ),
                    if (poll.hasVoted) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'You voted for\n${poll.votedOptionText} ✓',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Text('Your vote is anonymous.', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: AppSpacing.xxl),
                    TobboButton(label: 'Share this question', onPressed: () => _share(context, poll)),
                    const SizedBox(height: AppSpacing.sm),
                    TobboButton(
                      label: 'Back to Home',
                      secondary: true,
                      onPressed: () => context.go(AppRoutes.home),
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
