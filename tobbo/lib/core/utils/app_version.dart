import 'package:package_info_plus/package_info_plus.dart';

Future<String>? _appVersionLabel;

Future<String> appVersionLabel() {
  return _appVersionLabel ??= PackageInfo.fromPlatform().then((info) {
    final version = info.version.trim();
    if (version.isEmpty) return 'Tobbo';
    return 'Tobbo · v$version';
  });
}
