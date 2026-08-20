import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Tobbo/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl extends ChangeNotifier implements SettingsRepository {
  SettingsRepositoryImpl({required SharedPreferences prefs}) : _prefs = prefs {
    _hydrate();
  }

  static const _themeModeKey = 'tobbo_theme_mode';
  static const _nearbyEnabledKey = 'tobbo_nearby_enabled';
  static const _radiusKmKey = 'tobbo_radius_km';
  static const _locationAccessKey = 'tobbo_location_access';
  static const _notificationsEnabledKey = 'tobbo_notifications_enabled';

  static const double _minRadiusKm = 1;
  static const double _maxRadiusKm = 10;

  final SharedPreferences _prefs;
  AppPreferences _current = const AppPreferences();

  @override
  AppPreferences get current => _current;

  void _hydrate() {
    _current = AppPreferences(
      themeMode: _readThemeMode(),
      nearbyEnabled: _prefs.getBool(_nearbyEnabledKey) ?? true,
      radiusKm: (_prefs.getDouble(_radiusKmKey) ?? 5).clamp(_minRadiusKm, _maxRadiusKm),
      locationAccess: _prefs.getBool(_locationAccessKey) ?? true,
      notificationsEnabled: _prefs.getBool(_notificationsEnabledKey) ?? true,
    );
  }

  ThemeMode _readThemeMode() {
    switch (_prefs.getString(_themeModeKey)) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeName(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
  }

  void _persist() {
    _prefs.setString(_themeModeKey, _themeModeName(_current.themeMode));
    _prefs.setBool(_nearbyEnabledKey, _current.nearbyEnabled);
    _prefs.setDouble(_radiusKmKey, _current.radiusKm);
    _prefs.setBool(_locationAccessKey, _current.locationAccess);
    _prefs.setBool(_notificationsEnabledKey, _current.notificationsEnabled);
  }

  void _update(AppPreferences next) {
    _current = next;
    _persist();
    notifyListeners();
  }

  @override
  void setThemeMode(ThemeMode mode) {
    _update(_current.copyWith(themeMode: mode));
  }

  @override
  void setNearbyEnabled(bool value) {
    _update(_current.copyWith(nearbyEnabled: value));
  }

  @override
  void setRadiusKm(double value) {
    _update(_current.copyWith(radiusKm: value.clamp(_minRadiusKm, _maxRadiusKm)));
  }

  @override
  void setLocationAccess(bool value) {
    _update(_current.copyWith(locationAccess: value));
  }

  @override
  void setNotificationsEnabled(bool value) {
    _update(_current.copyWith(notificationsEnabled: value));
  }

  @override
  void reset() {
    _current = const AppPreferences();
    _prefs.remove(_themeModeKey);
    _prefs.remove(_nearbyEnabledKey);
    _prefs.remove(_radiusKmKey);
    _prefs.remove(_locationAccessKey);
    _prefs.remove(_notificationsEnabledKey);
    notifyListeners();
  }
}
