import '../../data/models/installed_app.dart';
import '../models/security_scan_result.dart';

class SecurityReportEngine {
  SecurityScanResult generate({
    required int score,
    required bool screenLock,
    required bool usbDebugging,
    required bool developerOptions,
    required bool rooted,
    required bool latestPatch,
    required bool deviceEncrypted,
    required int totalApps,
    required int userApps,
    required int systemApps,
    required int thirdPartyApps,
    required List<InstalledApp> installedApps,
    required List<InstalledApp> dangerousApps,
    required bool accessibilityEnabled,
    required bool notificationAccessEnabled,
    required bool overlayEnabled,
    required bool bootloaderUnlocked,
    required List<String> deviceAdminApps,
  }) {
    final List<SecurityIssue> critical = [];
    final List<SecurityIssue> warning = [];
    final List<SecurityIssue> safe = [];

    // Hidden suspicious apps must appear first with direct Fix Now.
    for (final app in installedApps) {
      if (app.hiddenApp &&
          !app.systemApp &&
          app.enabled &&
          !app.trustedInstaller) {
        critical.add(
          SecurityIssue(
            titleKey: 'hiddenSuspiciousApp',
            messageKey: 'hiddenAppDetected',
            canFix: true,
            actionKey: 'checkNow',
            args: {'packageName': app.packageName, 'appName': app.appName},
            packageName: app.packageName,
            appName: app.appName,
          ),
        );
      }
    }

    if (!latestPatch) {
      critical.add(
        const SecurityIssue(
          titleKey: 'securityUpdateOutdated',
          messageKey: 'updatePhone',
          canFix: true,
          actionKey: 'fix',
        ),
      );
    } else {
      safe.add(
        const SecurityIssue(
          titleKey: 'securityUpdate',
          messageKey: 'upToDate',
          canFix: false,
          actionKey: '',
        ),
      );
    }

    if (usbDebugging) {
      critical.add(
        const SecurityIssue(
          titleKey: 'usbDebuggingEnabled',
          messageKey: 'keepDisabled',
          canFix: true,
          actionKey: 'fix',
        ),
      );
    } else {
      safe.add(
        const SecurityIssue(
          titleKey: 'usbDebugging',
          messageKey: 'disabled',
          canFix: false,
          actionKey: '',
        ),
      );
    }

    if (developerOptions) {
      warning.add(
        const SecurityIssue(
          titleKey: 'developerOptionsEnabled',
          messageKey: 'turnOffIfNotNeeded',
          canFix: true,
          actionKey: 'fix',
        ),
      );
    } else {
      safe.add(
        const SecurityIssue(
          titleKey: 'developerOptions',
          messageKey: 'disabled',
          canFix: false,
          actionKey: '',
        ),
      );
    }

    if (!screenLock) {
      critical.add(
        const SecurityIssue(
          titleKey: 'screenLockNotEnabled',
          messageKey: 'setPinOrPattern',
          canFix: true,
          actionKey: 'fix',
        ),
      );
    } else {
      safe.add(
        const SecurityIssue(
          titleKey: 'screenLock',
          messageKey: 'active',
          canFix: false,
          actionKey: '',
        ),
      );
    }

    if (rooted) {
      critical.add(
        const SecurityIssue(
          titleKey: 'rootedPhone',
          messageKey: 'rootSecurityRisk',
          canFix: true,
          actionKey: 'checkNow',
        ),
      );
    } else {
      safe.add(
        const SecurityIssue(
          titleKey: 'rootNotFound',
          messageKey: 'secure',
          canFix: false,
          actionKey: '',
        ),
      );
    }

    if (accessibilityEnabled) {
      warning.add(
        const SecurityIssue(
          titleKey: 'accessibilityServices',
          messageKey: 'accessibilityEnabled',
          canFix: true,
          actionKey: 'checkNow',
        ),
      );
    }

    if (notificationAccessEnabled) {
      safe.add(
        const SecurityIssue(
          titleKey: 'notificationAccess',
          messageKey: 'notificationAccessEnabled',
          canFix: false,
          actionKey: 'checkNow',
        ),
      );
    }

    if (overlayEnabled) {
      warning.add(
        const SecurityIssue(
          titleKey: 'overlayApps',
          messageKey: 'overlayEnabled',
          canFix: true,
          actionKey: 'checkNow',
        ),
      );
    }

    if (bootloaderUnlocked) {
      warning.add(
        const SecurityIssue(
          titleKey: 'bootloaderUnlocked',
          messageKey: 'bootloaderRisk',
          canFix: true,
          actionKey: 'checkNow',
        ),
      );
    }

    // DEVICE ADMIN
    if (deviceAdminApps.isNotEmpty) {
      warning.add(
        SecurityIssue(
          titleKey: 'specialPhoneControl',
          messageKey: 'deviceAdminDetected',
          canFix: true,
          actionKey: 'checkNow',
          args: {'count': deviceAdminApps.length.toString()},
        ),
      );
    } else {
      safe.add(
        const SecurityIssue(
          titleKey: 'specialPhoneControl',
          messageKey: 'noUnknownDeviceAdmin',
          canFix: false,
          actionKey: '',
        ),
      );
    }

    return SecurityScanResult(
      score: score,
      critical: critical,
      warning: warning,
      safe: safe,
      totalApps: totalApps,
      userApps: userApps,
      systemApps: systemApps,
      thirdPartyApps: thirdPartyApps,
      installedApps: installedApps,
      dangerousApps: dangerousApps,
      deviceAdminApps: deviceAdminApps,
    );
  }
}
