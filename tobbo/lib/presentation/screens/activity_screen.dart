import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Tobbo/core/constants/app_spacing.dart';
import 'package:Tobbo/core/router/app_routes.dart';
import 'package:Tobbo/core/theme/tobbo_palette.dart';
import 'package:Tobbo/domain/entities/poll.dart';
import 'package:Tobbo/presentation/app_scope.dart';
import 'package:Tobbo/presentation/widgets/empty_state.dart';
import 'package:Tobbo/presentation/widgets/poll_card.dart';
import 'package:Tobbo/presentation/widgets/tobbo_loader.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialTab,
      child: AnimatedBuilder(
        animation: context.pollStore,
        builder: (context, _) {
          return FutureBuilder(
            future: Future.wait([
              context.pollStore.getMyPolls(),
              context.pollStore.getMyVotes(),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Scaffold(
                  body: SafeArea(child: Center(child: TobboLoader())),
                );
              }
              if (snapshot.hasError) {
                return Scaffold(
                  body: SafeArea(
                    child: EmptyState(
                      title: 'Something went wrong.',
                      message: snapshot.error.toString(),
                      actionLabel: 'Ask Tobbo',
                      onAction: () => context.push(AppRoutes.ask),
                    ),
                  ),
                );
              }
              final asked = snapshot.data?[0] ?? const <Poll>[];
              final voted = snapshot.data?[1] ?? const <Poll>[];
              return Scaffold(
                body: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, AppSpacing.pagePadding, 0),
                        child: ScreenHeader(title: 'Your activity', onBack: () => context.pop()),
                      ),
                      TabBar(
                        labelColor: context.palette.primaryText,
                        indicatorColor: context.palette.primary,
                        tabs: const [
                          Tab(text: 'Asked'),
                          Tab(text: 'Voted'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _PollList(
                              polls: asked,
                              emptyTitle: "You haven't asked anything yet.",
                              emptyMessage: 'Need a second opinion?',
                            ),
                            _PollList(
                              polls: voted,
                              emptyTitle: "You haven't voted yet.",
                              emptyMessage: 'Explore questions and share your opinion anonymously.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PollList extends StatelessWidget {
  const _PollList({
    required this.polls,
    required this.emptyTitle,
    required this.emptyMessage,
  });

  final List<Poll> polls;
  final String emptyTitle;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (polls.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: EmptyState(
          title: emptyTitle,
          message: emptyMessage,
          actionLabel: 'Ask Tobbo',
          onAction: () => context.push(AppRoutes.ask),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      itemCount: polls.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final poll = polls[index];
        return PollCard(
          poll: poll,
          onTap: () => context.push(
            poll.hasVoted || poll.isClosed ? AppRoutes.results(poll.publicCode) : AppRoutes.poll(poll.publicCode),
          ),
        );
      },
    );
  }
}
