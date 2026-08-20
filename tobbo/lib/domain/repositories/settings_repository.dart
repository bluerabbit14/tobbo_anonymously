import 'package:flutter/material.dart';

class AppPreferences {
  const AppPreferences({
    this.themeMode = ThemeMode.system,
    this.nearbyEnabled = true,
    this.radiusKm = 5,
    this.locationAccess = true,
    this.notificationsEnabled = true,
  });

  final ThemeMode themeMode;
  final bool nearbyEnabled;
  final double radiusKm;
  final bool locationAccess;
  final bool notificationsEnabled;

  AppPreferences copyWith({
    ThemeMode? themeMode,
    bool? nearbyEnabled,
    double? radiusKm,
    bool? locationAccess,
    bool? notificationsEnabled,
  }) {
    return AppPreferences(
      themeMode: themeMode ?? this.themeMode,
      nearbyEnabled: nearbyEnabled ?? this.nearbyEnabled,
      radiusKm: radiusKm ?? this.radiusKm,
      locationAccess: locationAccess ?? this.locationAccess,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

abstract class SettingsRepository {
  AppPreferences get current;

  void setThemeMode(ThemeMode mode);

  void setNearbyEnabled(bool value);

  void setRadiusKm(double value);

  void setLocationAccess(bool value);

  void setNotificationsEnabled(bool value);

  void reset();
}
