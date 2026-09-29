class InstalledApp {
  final String appName;
  final String packageName;

  final String versionName;
  final int versionCode;

  final bool enabled;
  final bool systemApp;
  final bool hiddenApp;

  final int targetSdk;

  final String installerName;
  final String sourceType;
  final bool trustedInstaller;

  final List<String> requestedPermissions;
  final List<String> sensitivePermissions;

  const InstalledApp({
    required this.appName,
    required this.packageName,
    required this.versionName,
    required this.versionCode,
    required this.enabled,
    required this.systemApp,
    required this.hiddenApp,
    required this.targetSdk,
    required this.installerName,
    required this.sourceType,
    required this.trustedInstaller,
    required this.requestedPermissions,
    required this.sensitivePermissions,
  });

  factory InstalledApp.fromMap(Map<String, dynamic> map) {
    final installer = Map<String, dynamic>.from(map["installer"] ?? {});

    final permissionAnalysis = Map<String, dynamic>.from(
      map["permissionAnalysis"] ?? {},
    );

    return InstalledApp(
      appName: map["appName"] ?? "",
      packageName: map["packageName"] ?? "",
      versionName: map["versionName"] ?? "",
      versionCode: map["versionCode"] ?? 0,

      enabled: map["enabled"] ?? true,
      systemApp: map["systemApp"] ?? false,

      hiddenApp: map["hiddenApp"] ?? false,

      targetSdk: map["targetSdk"] ?? 0,

      installerName: installer["installerName"] ?? "Unknown",

      sourceType: installer["sourceType"] ?? "UNKNOWN_SOURCE",

      trustedInstaller: installer["trusted"] ?? false,

      requestedPermissions: List<String>.from(
        map["requestedPermissions"] ?? [],
      ),

      sensitivePermissions: List<String>.from(
        permissionAnalysis["sensitivePermissions"] ?? [],
      ),
    );
  }
}
