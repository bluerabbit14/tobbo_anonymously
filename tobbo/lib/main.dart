import 'package:flutter/material.dart';
import 'package:Tobbo/core/router/app_router.dart';
import 'package:Tobbo/core/theme/app_theme.dart';
import 'package:Tobbo/data/datasources/sample_poll_datasource.dart';
import 'package:Tobbo/data/repositories/poll_repository_impl.dart';
import 'package:Tobbo/data/repositories/session_repository_impl.dart';
import 'package:Tobbo/data/repositories/settings_repository_impl.dart';
import 'package:Tobbo/presentation/app_scope.dart';

void main() {
  final polls = PollRepositoryImpl(SamplePollDataSource());
  final settings = SettingsRepositoryImpl();
  final sessions = SessionRepositoryImpl();
  runApp(
    RepositoryScope(
      polls: polls,
      settings: settings,
      sessions: sessions,
      child: TobboApp(settings: settings),
    ),
  );
}

class TobboApp extends StatelessWidget {
  const TobboApp({super.key, required this.settings});

  final SettingsRepositoryImpl settings;

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
          routerConfig: appRouter,
        );
      },
    );
  }
}
