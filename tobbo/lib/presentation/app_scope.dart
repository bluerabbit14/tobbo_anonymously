import 'package:flutter/material.dart';
import 'package:Tobbo/data/repositories/poll_repository_impl.dart';
import 'package:Tobbo/data/repositories/settings_repository_impl.dart';
import 'package:Tobbo/domain/repositories/poll_repository.dart';
import 'package:Tobbo/domain/repositories/session_repository.dart';
import 'package:Tobbo/domain/repositories/settings_repository.dart';

class RepositoryScope extends InheritedWidget {
  const RepositoryScope({
    super.key,
    required this.polls,
    required this.settings,
    required this.sessions,
    required super.child,
  });

  final PollRepository polls;
  final SettingsRepository settings;
  final SessionRepository sessions;

  static RepositoryScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<RepositoryScope>();
    assert(scope != null, 'RepositoryScope not found');
    return scope!;
  }

  Listenable get listenable => Listenable.merge([
        if (polls is Listenable) polls as Listenable,
        if (settings is Listenable) settings as Listenable,
      ]);

  @override
  bool updateShouldNotify(RepositoryScope oldWidget) {
    return polls != oldWidget.polls ||
        settings != oldWidget.settings ||
        sessions != oldWidget.sessions;
  }
}

extension RepositoryScopeX on BuildContext {
  RepositoryScope get repos => RepositoryScope.of(this);

  PollRepositoryImpl get pollStore => repos.polls as PollRepositoryImpl;

  SettingsRepositoryImpl get settingsStore => repos.settings as SettingsRepositoryImpl;

  SessionRepository get sessionStore => repos.sessions;
}
