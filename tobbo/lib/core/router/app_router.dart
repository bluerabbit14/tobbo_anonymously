import 'package:go_router/go_router.dart';
import 'package:Tobbo/core/router/app_routes.dart';
import 'package:Tobbo/presentation/screens/activity_screen.dart';
import 'package:Tobbo/presentation/screens/create_poll_screen.dart';
import 'package:Tobbo/presentation/screens/home_screen.dart';
import 'package:Tobbo/presentation/screens/onboarding_screen.dart';
import 'package:Tobbo/presentation/screens/poll_detail_screen.dart';
import 'package:Tobbo/presentation/screens/results_screen.dart';
import 'package:Tobbo/presentation/screens/setting_screen.dart';
import 'package:Tobbo/presentation/widgets/app_shell.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.welcome,
  routes: [
    GoRoute(
      path: AppRoutes.welcome,
      builder: (context, state) => const OnboardingScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.settings,
              builder: (context, state) => const SettingScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.ask,
      builder: (context, state) => const CreatePollScreen(),
    ),
    GoRoute(
      path: AppRoutes.create,
      redirect: (context, state) => AppRoutes.ask,
    ),
    GoRoute(
      path: AppRoutes.pollDetail,
      builder: (context, state) {
        final code = state.pathParameters['code'] ?? '';
        return PollDetailScreen(code: code);
      },
      routes: [
        GoRoute(
          path: 'results',
          builder: (context, state) {
            final code = state.pathParameters['code'] ?? '';
            return ResultsScreen(code: code);
          },
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.sharedPoll,
      builder: (context, state) {
        final code = state.pathParameters['code'] ?? '';
        return PollDetailScreen(code: code, shared: true);
      },
    ),
    GoRoute(
      path: AppRoutes.activity,
      builder: (context, state) => const ActivityScreen(),
    ),
    GoRoute(
      path: AppRoutes.myQuestions,
      builder: (context, state) => const ActivityScreen(),
    ),
    GoRoute(
      path: AppRoutes.myVotes,
      builder: (context, state) => const ActivityScreen(initialTab: 1),
    ),
  ],
);
