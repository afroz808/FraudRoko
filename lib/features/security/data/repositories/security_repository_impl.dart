import '../../domain/engine/security_report_engine.dart';
import '../../domain/models/security_scan_result.dart';
import '../datasources/device_info_datasource.dart';
import '../models/installed_app.dart';

class SecurityRepositoryImpl {
  final DeviceInfoDataSource dataSource;

  SecurityRepositoryImpl(this.dataSource);

  Future<SecurityScanResult> scanPhone() async {
    final data = await dataSource.getDeviceInfo();

    final deviceInfo = Map<String, dynamic>.from(data["deviceInfo"] ?? {});

    final securitySettings = Map<String, dynamic>.from(
      data["securitySettings"] ?? {},
    );

    final installedApps = Map<String, dynamic>.from(
      data["installedApps"] ?? {},
    );

    // =========================================
    // INSTALLED APPS
    // =========================================

    final List<InstalledApp> installedAppList =
        (installedApps["apps"] as List<dynamic>? ?? [])
            .map((app) => InstalledApp.fromMap(Map<String, dynamic>.from(app)))
            .toList();

    // =========================================
    // DEVICE ADMIN
    // =========================================

    final deviceAdmins = Map<String, dynamic>.from(data["deviceAdmins"] ?? {});

    final List<String> deviceAdminApps =
        (deviceAdmins["deviceAdmins"] as List<dynamic>? ?? [])
            .map((admin) => Map<String, dynamic>.from(admin))
            .map((admin) {
              final packageName = admin["packageName"]?.toString() ?? "";

              if (packageName.isEmpty) {
                return "";
              }

              final matchingApp = installedAppList
                  .where((app) => app.packageName == packageName)
                  .cast<InstalledApp?>()
                  .firstWhere((app) => app != null, orElse: () => null);

              if (matchingApp != null && matchingApp.appName.isNotEmpty) {
                return matchingApp.appName;
              }

              return "अनजान ऐप";
            })
            .where((appName) => appName.isNotEmpty)
            .toList();

    // Only apps with a real security concern are dangerous.
    // Unknown installer/source alone is NOT enough.
    final dangerousApps = installedAppList.where((app) {
      return app.sensitivePermissions.length >= 5;
    }).toList();

    final bool screenLock =
        securitySettings["screenLockEnabled"] as bool? ?? false;

    final bool usbDebugging =
        securitySettings["usbDebuggingEnabled"] as bool? ?? false;

    final bool developerOptions =
        securitySettings["developerOptionsEnabled"] as bool? ?? false;

    final bool rooted = securitySettings["rootDetected"] as bool? ?? false;

    final bool deviceEncrypted =
        securitySettings["deviceEncrypted"] as bool? ?? false;

    // Native Android SecurityRuleEngine is the primary score source.
    final securityAnalysis = Map<String, dynamic>.from(
      data["securityAnalysis"] ?? {},
    );

    final int? nativeScore = (securityAnalysis["score"] as num?)?.toInt();

    final String securityPatch = deviceInfo["securityPatch"]?.toString() ?? "";

    final bool latestPatch =
        securityPatch.isNotEmpty && securityPatch != "Unknown";

    final int totalApps = installedApps["totalApps"] as int? ?? 0;

    final int userApps = installedApps["userApps"] as int? ?? 0;

    final int systemApps = installedApps["systemApps"] as int? ?? 0;

    final int thirdPartyApps =
        installedApps["thirdPartyApps"] as int? ?? (totalApps - systemApps);

    final int score = nativeScore ?? 100;

    return SecurityReportEngine().generate(
      score: score,
      screenLock: screenLock,
      usbDebugging: usbDebugging,
      developerOptions: developerOptions,
      rooted: rooted,
      latestPatch: latestPatch,
      deviceEncrypted: deviceEncrypted,
      totalApps: totalApps,
      userApps: userApps,
      systemApps: systemApps,
      thirdPartyApps: thirdPartyApps,
      installedApps: installedAppList,
      dangerousApps: dangerousApps,
      accessibilityEnabled:
          ((data["accessibility"]?["services"] as List?)?.isNotEmpty ?? false),
      notificationAccessEnabled:
          ((data["notificationAccess"]?["services"] as List?)?.isNotEmpty ??
          false),
      overlayEnabled:
          ((data["overlay"]?["apps"] as List?)?.isNotEmpty ?? false),
      bootloaderUnlocked: data["bootloader"]?["unlocked"] as bool? ?? false,

      // NEW
      deviceAdminApps: deviceAdminApps,
    );
  }
}
