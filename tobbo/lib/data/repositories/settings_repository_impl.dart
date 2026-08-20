import 'package:flutter/material.dart';
import 'package:Tobbo/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl extends ChangeNotifier implements SettingsRepository {
  AppPreferences _current = const AppPreferences();

  @override
  AppPreferences get current => _current;

  @override
  void setThemeMode(ThemeMode mode) {
    _current = _current.copyWith(themeMode: mode);
    notifyListeners();
  }

  @override
  void setNearbyEnabled(bool value) {
    _current = _current.copyWith(nearbyEnabled: value);
    notifyListeners();
  }

  @override
  void setRadiusKm(double value) {
    _current = _current.copyWith(radiusKm: value);
    notifyListeners();
  }

  @override
  void setLocationAccess(bool value) {
    _current = _current.copyWith(locationAccess: value);
    notifyListeners();
  }

  @override
  void setNotificationsEnabled(bool value) {
    _current = _current.copyWith(notificationsEnabled: value);
    notifyListeners();
  }

  @override
  void reset() {
    _current = const AppPreferences();
    notifyListeners();
  }
}
