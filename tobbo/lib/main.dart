import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Tobbo/core/router/app_router.dart';
import 'package:Tobbo/core/theme/app_theme.dart';
import 'package:Tobbo/data/repositories/poll_repository_impl.dart';
import 'package:Tobbo/data/repositories/session_repository_impl.dart';
import 'package:Tobbo/data/repositories/settings_repository_impl.dart';
import 'package:Tobbo/data/services/api_service.dart';
import 'package:Tobbo/data/services/location_service.dart';
import 'package:Tobbo/presentation/app_scope.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final tokens = AuthTokenStore();
  final api = ApiService(tokenStore: tokens);
  final sessions = SessionRepositoryImpl(api: api, tokens: tokens, prefs: prefs);
  api.refreshToken = () async {
    await sessions.refreshSession();
  };
  final polls = PollRepositoryImpl(
    api: api,
    location: LocationService(),
    sessions: sessions,
  );
  final settings = SettingsRepositoryImpl();
  runApp(
    RepositoryScope(
      polls: polls,
      settings: settings,
      sessions: sessions,
      child: TobboApp(
        settings: settings,
        router: createAppRouter(sessions),
      ),
    ),
  );
}

class TobboApp extends StatelessWidget {
  const TobboApp({
    super.key,
    required this.settings,
    required this.router,
  });

  final SettingsRepositoryImpl settings;
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        return MaterialApp.router(
          title: 'Tobbo',
          debugShowCheckedModeBanner: false,
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: settings.current.themeMode,
          routerConfig: router,
        );
      },
    );
  }
}
