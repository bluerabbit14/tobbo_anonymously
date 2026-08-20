import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class OnboardingPermissionResult {
  const OnboardingPermissionResult({
    required this.locationGranted,
    required this.notificationsGranted,
  });

  final bool locationGranted;
  final bool notificationsGranted;
}

class PermissionService {
  Future<OnboardingPermissionResult> requestOnboarding() async {
    final locationGranted = await _requestLocation();
    final notificationsGranted = await _requestNotifications();
    return OnboardingPermissionResult(
      locationGranted: locationGranted,
      notificationsGranted: notificationsGranted,
    );
  }

  Future<bool> _requestLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _requestNotifications() async {
    try {
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (_) {
      return false;
    }
  }
}
