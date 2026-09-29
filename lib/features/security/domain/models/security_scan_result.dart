import '../../data/models/installed_app.dart';

class SecurityScanResult {
  final int score;

  final List<SecurityIssue> critical;
  final List<SecurityIssue> warning;
  final List<SecurityIssue> safe;

  final int totalApps;
  final int userApps;
  final int systemApps;
  final int thirdPartyApps;

  final List<InstalledApp> installedApps;
  final List<InstalledApp> dangerousApps;

  final List<String> deviceAdminApps;

  const SecurityScanResult({
    required this.score,
    required this.critical,
    required this.warning,
    required this.safe,
    required this.totalApps,
    required this.userApps,
    required this.systemApps,
    required this.thirdPartyApps,
    required this.installedApps,
    required this.dangerousApps,
    this.deviceAdminApps = const [],
  });
}

class SecurityIssue {
  /// Stable localization key. Never store translated UI text here.
  final String titleKey;
  final String messageKey;
  final String actionKey;
  final bool canFix;

  /// Optional values used by localized messages.
  final Map<String, String> args;
  final String? packageName;
  final String? appName;

  const SecurityIssue({
    required this.titleKey,
    required this.messageKey,
    required this.canFix,
    required this.actionKey,
    this.args = const {},
    this.packageName,
    this.appName,
  });
}
