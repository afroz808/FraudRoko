import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_text.dart';

import '../../../core/channels/settings_channel.dart';
import '../../../core/widgets/app_icon_widget.dart';
import 'installed_apps_screen.dart';
import '../domain/models/security_scan_result.dart';
import 'providers/security_provider.dart';

class SecurityScreen extends StatelessWidget {
  final SecurityScanResult? initialResult;

  const SecurityScreen({super.key, this.initialResult});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = SecurityProvider();
        if (initialResult != null) {
          provider.securityResult = initialResult;
        } else {
          provider.scanPhone();
        }
        return provider;
      },
      child: const _SecurityView(),
    );
  }
}

class _SecurityView extends StatefulWidget {
  const _SecurityView();

  @override
  State<_SecurityView> createState() => _SecurityViewState();
}

class _SecurityViewState extends State<_SecurityView>
    with WidgetsBindingObserver {
  static const Color blue = Color(0xff1565FF);
  static const Color darkBlue = Color(0xff0F4C81);
  static const Color background = Color(0xffF8FAFC);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  DateTime? _lastResumeScan;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !mounted) return;
    final now = DateTime.now();
    if (_lastResumeScan != null &&
        now.difference(_lastResumeScan!) < const Duration(milliseconds: 700)) {
      return;
    }
    _lastResumeScan = now;
    Future<void>.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      final provider = context.read<SecurityProvider>();
      if (!provider.isLoading) provider.scanPhone();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SecurityProvider>();

    if (provider.isLoading && provider.securityResult == null) {
      return const Scaffold(
        backgroundColor: background,
        body: Center(child: CircularProgressIndicator(color: blue)),
      );
    }

    if (provider.error != null) {
      return Scaffold(
        backgroundColor: background,
        appBar: _appBar(context),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(provider.error!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    final result = provider.securityResult;

    if (result == null) {
      return Scaffold(
        backgroundColor: background,
        appBar: _appBar(context),
        body: Center(
          child: Text(AppText.t(context, "सुरक्षा रिपोर्ट उपलब्ध नहीं है")),
        ),
      );
    }

    // IMPORTANT:
    // System apps को user-installed apps की गिनती में नहीं रखेंगे।
    final userApps = result.installedApps
        .where((app) => !app.systemApp)
        .toList();

    // =========================================
    // APP CATEGORIES
    // =========================================

    // Hidden apps ko alag category mein rakhenge.
    final hiddenApps = userApps.where((app) => app.hiddenApp).toList();

    // Hidden apps ko baaki categories mein repeat nahi karenge.
    final visibleApps = userApps.where((app) => !app.hiddenApp).toList();

    // Play Store + official app stores.
    final safeApps = visibleApps.where((app) {
      return app.sourceType == "PLAY_STORE" ||
          app.sourceType == "SAMSUNG_STORE" ||
          app.sourceType == "XIAOMI_STORE" ||
          app.sourceType == "HUAWEI_STORE" ||
          app.sourceType == "AMAZON_STORE" ||
          app.sourceType == "OTHER_STORE";
    }).toList();

    // Clearly identified APK/local/downloaded apps.
    final outsideApps = visibleApps.where((app) {
      return app.sourceType == "LOCAL_FILE" ||
          app.sourceType == "DOWNLOADED_FILE";
    }).toList();

    final totalProblems = result.critical.length + result.warning.length;

    final hasCritical = result.critical.isNotEmpty;
    final hasProblems = totalProblems > 0;

    return Scaffold(
      backgroundColor: background,
      appBar: _appBar(context),
      body: RefreshIndicator(
        color: blue,
        onRefresh: provider.scanPhone,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            // =========================================
            // SECURITY STATUS
            // =========================================
            _buildStatusCard(
              context: context,
              score: result.score,
              problemCount: totalProblems,
              hasCritical: hasCritical,
            ),
            const SizedBox(height: 22),

            // =========================================
            // PROBLEMS
            // =========================================
            if (hasProblems) ...[
              _sectionHeader(
                title: AppText.t(context, "पहले इन्हें ठीक करें"),
                subtitle: AppText.t(context, "securityProblemsFound", {
                  "count": totalProblems.toString(),
                }),
                icon: Icons.build_rounded,
                color: hasCritical ? Colors.red : Colors.orange,
              ),

              const SizedBox(height: 12),

              ...result.critical.map(
                (issue) => _issueCard(context, issue, isCritical: true),
              ),

              ...result.warning.map(
                (issue) => _issueCard(context, issue, isCritical: false),
              ),
            ],

            // =========================================
            // SAFE CHECKS
            // =========================================
            if (result.safe.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildSafeChecks(context, result.safe),
            ],

            const SizedBox(height: 22),

            // =========================================
            // APPS
            // =========================================
            _sectionHeader(
              title: AppText.t(context, "आपके ऐप्स"),
              subtitle: AppText.t(
                context,
                AppText.t(context, "सिर्फ आपके द्वारा इंस्टॉल किए गए ऐप्स"),
              ),
              icon: Icons.apps_rounded,
              color: blue,
            ),

            const SizedBox(height: 12),

            Text(
              AppText.t(context, 'Installed apps'),
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),

            /// SAFE APPS
            _appCategory(
              context: context,
              title: AppText.t(context, "सुरक्षित ऐप्स"),
              description: AppText.t(
                context,
                AppText.t(
                  context,
                  "Play Store या official app store से इंस्टॉल किए गए ऐप्स",
                ),
              ),
              count: safeApps.length,
              color: Colors.green,
              icon: Icons.verified_rounded,
              apps: safeApps,
            ),

            const SizedBox(height: 10),

            // OUTSIDE STORE APPS
            _appCategory(
              context: context,
              title: AppText.t(context, "बाहर से इंस्टॉल ऐप्स"),
              description: outsideApps.isEmpty
                  ? AppText.t(context, "कोई ऐप बाहर से इंस्टॉल नहीं मिला")
                  : "इन ऐप्स को ध्यान से check करें",
              count: outsideApps.length,
              color: outsideApps.isEmpty ? Colors.green : Colors.orange,
              icon: outsideApps.isEmpty
                  ? Icons.verified_user_rounded
                  : Icons.warning_rounded,
              apps: outsideApps,
            ),
            const SizedBox(height: 10),

            // HIDDEN APPS
            _appCategory(
              context: context,
              title: AppText.t(context, "छिपे हुए ऐप्स"),
              description: hiddenApps.isEmpty
                  ? AppText.t(context, "कोई छिपा हुआ ऐप नहीं मिला")
                  : AppText.t(
                      context,
                      AppText.t(
                        context,
                        "कुछ ऐप phone की normal app list में दिखाई नहीं दे रहे हैं",
                      ),
                    ),
              count: hiddenApps.length,
              color: hiddenApps.isEmpty ? Colors.green : Colors.orange,
              icon: hiddenApps.isEmpty
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              apps: hiddenApps,
            ),

            const SizedBox(height: 22),

            // =========================================
            // NO FAKE HIGH-RISK APP LIST
            // =========================================
            // dangerousApps को अभी यहाँ नहीं दिखा रहे।
            // क्योंकि सिर्फ permissions की वजह से Google,
            // Settings या trusted apps को risky बताना गलत है।
            //
            // जब risk-engine properly fix होगा,
            // तभी यहाँ High Risk Apps दिखाएँगे।

            // =========================================
            // RESCAN
            // =========================================
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: provider.isLoading ? null : provider.scanPhone,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(
                  AppText.t(context, "फिर से जाँच करें"),
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: blue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: blue),
      title: Text(
        AppText.t(context, "Security Report"),
        style: TextStyle(
          color: darkBlue,
          fontSize: 19,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required BuildContext context,
    required int score,
    required int problemCount,
    required bool hasCritical,
  }) {
    final Color color;

    if (problemCount == 0) {
      color = Colors.green;
    } else if (hasCritical) {
      color = Colors.red;
    } else {
      color = Colors.orange;
    }

    final String title;

    if (problemCount == 0) {
      title = AppText.t(context, "Your phone looks safe.");
    } else if (hasCritical) {
      title = AppText.t(context, "Your phone’s security needs attention.");
    } else {
      title = AppText.t(context, "कुछ चीज़ों पर ध्यान दें");
    }

    final String message;

    if (problemCount == 0) {
      message = AppText.t(context, "कोई महत्वपूर्ण सुरक्षा समस्या नहीं मिली।");
    } else {
      message = AppText.t(context, "securityProblemsFound", {
        "count": problemCount.toString(),
      });
    }

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: blue.withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              problemCount == 0
                  ? Icons.verified_user_rounded
                  : Icons.shield_rounded,
              color: color,
              size: 42,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            AppText.t(context, "सुरक्षा स्तर"),
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),

          const SizedBox(height: 3),

          Text(
            "$score/100",
            style: TextStyle(
              color: color,
              fontSize: 42,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: darkBlue,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff111827),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _issueCard(
    BuildContext context,
    dynamic issue, {
    required bool isCritical,
  }) {
    final Color color = isCritical ? Colors.red : Colors.orange;
    final bool isHiddenAppIssue = issue.titleKey == 'hiddenSuspiciousApp';
    final String detectedAppName = (issue.appName?.isNotEmpty ?? false)
        ? issue.appName!
        : (issue.args['appName'] ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isHiddenAppIssue
                  ? Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AppIconWidget(
                          packageName:
                              issue.packageName ??
                              issue.args['packageName'] ??
                              '',
                          size: 52,
                        ),
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            width: 23,
                            height: 23,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.priority_high_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        isCritical
                            ? Icons.error_rounded
                            : Icons.warning_amber_rounded,
                        color: color,
                      ),
                    ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isHiddenAppIssue && detectedAppName.isNotEmpty
                      ? detectedAppName
                      : AppText.t(context, issue.titleKey, issue.args),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 11),

          Text(
            AppText.t(context, issue.messageKey, issue.args),
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
              height: 1.45,
            ),
          ),

          if (issue.canFix) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    if (issue.titleKey == 'screenLockNotEnabled') {
                      await SettingsChannel.openSecuritySettings();
                    } else if (issue.titleKey == 'usbDebuggingEnabled') {
                      await SettingsChannel.openDeveloperOptions();
                    } else if (issue.titleKey == 'developerOptionsEnabled') {
                      await SettingsChannel.openDeveloperOptions();
                    } else if (issue.titleKey == 'securityUpdateOutdated') {
                      await SettingsChannel.openSystemUpdate();
                    } else if (issue.titleKey == 'specialPhoneControl') {
                      await SettingsChannel.openSecuritySettings();
                    } else if (issue.titleKey == 'rootedPhone') {
                      await SettingsChannel.openSecuritySettings();
                    } else if (issue.titleKey == 'accessibilityServices') {
                      await SettingsChannel.openAccessibilitySettings();
                    } else if (issue.titleKey == 'notificationAccess') {
                      await SettingsChannel.openNotificationAccessSettings();
                    } else if (issue.titleKey == 'overlayApps') {
                      await SettingsChannel.openOverlaySettings();
                    } else if (issue.args?['packageName'] != null) {
                      await SettingsChannel.openAppDetails(
                        issue.args!['packageName']!,
                      );
                    }
                  } catch (e) {
                    debugPrint("FraudRoko Settings Error: $e");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: Text(
                  AppText.t(context, issue.actionKey, issue.args),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSafeChecks(BuildContext context, List safe) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: blue.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_rounded, color: Colors.green),
              SizedBox(width: 9),
              Text(
                AppText.t(context, "सुरक्षित जाँच"),
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ...safe.map(
            (issue) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                    size: 18,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      AppText.t(context, issue.titleKey, issue.args),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _appCategory({
    required BuildContext context,
    required String title,
    required String description,
    required int count,
    required Color color,
    required IconData icon,
    required List apps,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(19),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                InstalledAppsScreen(apps: apps.cast()),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: color.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 25),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Column(
              children: [
                Text(
                  "$count",
                  style: TextStyle(
                    color: color,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: Colors.black38,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
