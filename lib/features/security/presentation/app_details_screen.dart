import 'package:flutter/material.dart';

import '../../../core/localization/app_text.dart';
import '../../../core/channels/app_settings_channel.dart';
import '../../../core/widgets/app_icon_widget.dart';
import '../data/models/installed_app.dart';

class AppDetailsScreen extends StatelessWidget {
  final InstalledApp app;

  const AppDetailsScreen({super.key, required this.app});

  // ------------------------------------------------------------
  // PERMISSION -> USER FRIENDLY CAPABILITY
  // Duplicate Android permissions are grouped into one capability.
  // ------------------------------------------------------------

  Map<String, IconData> _capabilities() {
    final result = <String, IconData>{};

    for (final permission in app.sensitivePermissions) {
      final p = permission.toUpperCase();

      if (p.contains('LOCATION')) {
        result.putIfAbsent('📍 स्थान', () => Icons.location_on_rounded);
      } else if (p.contains('CAMERA')) {
        result.putIfAbsent('📷 कैमरा', () => Icons.camera_alt_rounded);
      } else if (p.contains('AUDIO') || p.contains('RECORD_AUDIO')) {
        result.putIfAbsent('🎤 माइक्रोफ़ोन', () => Icons.mic_rounded);
      } else if (p.contains('CONTACT')) {
        result.putIfAbsent('👥 संपर्क', () => Icons.contacts_rounded);
      } else if (p.contains('SMS')) {
        result.putIfAbsent('💬 संदेश', () => Icons.sms_rounded);
      } else if (p.contains('PHONE') ||
          p.contains('CALL') ||
          p.contains('READ_PHONE')) {
        result.putIfAbsent('📞 फ़ोन', () => Icons.phone_rounded);
      } else if (p.contains('BLUETOOTH')) {
        result.putIfAbsent('🔵 ब्लूटूथ', () => Icons.bluetooth_rounded);
      } else if (p.contains('CALENDAR')) {
        result.putIfAbsent('📅 कैलेंडर', () => Icons.calendar_month_rounded);
      } else if (p.contains('STORAGE') ||
          p.contains('FILE') ||
          p.contains('MEDIA')) {
        result.putIfAbsent('📁 फ़ाइलें', () => Icons.folder_rounded);
      } else {
        result.putIfAbsent('🔐 अन्य', () => Icons.security_rounded);
      }
    }

    return result;
  }

  // ------------------------------------------------------------
  // TOP APP CARD
  // ------------------------------------------------------------

  Widget _appHeader(BuildContext context) {
    final safe = app.trustedInstaller;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 450),
      tween: Tween(begin: 0.94, end: 1),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            AppIconWidget(packageName: app.packageName, size: 76),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.appName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF101828),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: safe
                          ? Colors.green.shade50
                          : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          safe
                              ? Icons.verified_rounded
                              : Icons.warning_amber_rounded,
                          size: 18,
                          color: safe
                              ? Colors.green.shade700
                              : Colors.orange.shade800,
                        ),
                        const SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            safe
                                ? AppText.t(
                                    context,
                                    AppText.t(
                                      context,
                                      "प्ले स्टोर से जोड़ा गया",
                                    ),
                                  )
                                : AppText.t(
                                    context,
                                    AppText.t(context, "बाहर से जोड़ा गया"),
                                  ),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: safe
                                  ? Colors.green.shade800
                                  : Colors.orange.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: safe ? Colors.green.shade50 : Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                safe ? Icons.shield_rounded : Icons.warning_rounded,
                color: safe ? Colors.green.shade600 : Colors.orange.shade700,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // SAFE / WARNING CARD
  // ------------------------------------------------------------

  Widget _statusCard(BuildContext context) {
    final safe = app.trustedInstaller;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: safe ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: safe ? Colors.green.shade100 : Colors.orange.shade100,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: safe ? Colors.green.shade100 : Colors.orange.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              safe ? Icons.shield_rounded : Icons.warning_rounded,
              color: safe ? Colors.green.shade700 : Colors.orange.shade800,
              size: 31,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  safe
                      ? AppText.t(
                          context,
                          AppText.t(context, "यह ऐप सुरक्षित है"),
                        )
                      : AppText.t(
                          context,
                          AppText.t(context, "सावधानी: यह ऐप बाहर से आया है"),
                        ),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: safe
                        ? Colors.green.shade800
                        : Colors.orange.shade900,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  safe
                      ? AppText.t(
                          context,
                          AppText.t(
                            context,
                            "FraudRoko को इस ऐप में कोई खतरे का संकेत नहीं मिला।",
                          ),
                        )
                      : AppText.t(
                          context,
                          AppText.t(
                            context,
                            "यह ऐप Play Store के बाहर से आया है। अगर आपने इसे खुद इंस्टॉल नहीं किया है, तो सावधान रहें।",
                          ),
                        ),
                  style: const TextStyle(fontSize: 15, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // CAPABILITY CARD
  // ------------------------------------------------------------

  Widget _capabilityCard(BuildContext context) {
    final capabilities = _capabilities();
    final entries = capabilities.entries.toList();

    const maxVisible = 5;

    final visible = entries.take(maxVisible).toList();
    final remaining = entries.length - visible.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.apps_rounded, color: Colors.blue.shade700),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  AppText.t(
                    context,
                    AppText.t(context, "यह ऐप क्या कर सकता है?"),
                  ),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              Text(
                "$remaining",
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.all(18),
              child: Text(
                AppText.t(
                  context,
                  AppText.t(
                    context,
                    "इस ऐप को कोई महत्वपूर्ण सुविधा नहीं मिली।",
                  ),
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 15),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visible.length + (remaining > 0 ? 1 : 0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.05,
              ),
              itemBuilder: (context, index) {
                if (index == visible.length) {
                  return _capabilityItem(
                    icon: Icons.add_rounded,
                    label: "+$remaining",
                  );
                }

                final item = visible[index];

                return _capabilityItem(
                  icon: item.value,
                  label: AppText.t(context, item.key),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _capabilityItem({required IconData icon, required String label}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.blue.shade50),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 29, color: Colors.blue.shade600),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // FRAUDROKO ADVICE
  // ------------------------------------------------------------

  Widget _fraudRokoAdvice(BuildContext context) {
    final safe = app.trustedInstaller;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.amber.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/cyber_assistant.png',
            width: 82,
            height: 82,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) {
              return const SizedBox(
                width: 82,
                height: 82,
                child: Icon(
                  Icons.support_agent_rounded,
                  size: 58,
                  color: Colors.blue,
                ),
              );
            },
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppText.t(context, AppText.t(context, "FraudRoko की सलाह")),
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  safe
                      ? AppText.t(
                          context,
                          AppText.t(
                            context,
                            "यह ऐप सामान्य रूप से इस्तेमाल किया जा सकता है। फिर भी वही अनुमति दें जिसकी जरूरत हो।",
                          ),
                        )
                      : AppText.t(
                          context,
                          AppText.t(
                            context,
                            "यह ऐप बाहर से आया है। आपकी बैंकिंग जानकारी, निजी जानकारी या फोन का गलत इस्तेमाल हो सकता है। अगर आपने इसे खुद इंस्टॉल नहीं किया है, तो इसे हटाने पर विचार करें।",
                          ),
                        ),
                  style: const TextStyle(fontSize: 14, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // DELETE BUTTON
  // IMPORTANT:
  // SAFE APP => NO DELETE BUTTON
  // OUTSIDE SOURCE => DELETE ACTION
  // ------------------------------------------------------------

  Widget _deleteButton(BuildContext context) {
    if (app.trustedInstaller) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      height: 62,
      child: ElevatedButton.icon(
        onPressed: () async {
          await AppSettingsChannel.openAppSettings(app.packageName);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        icon: const Icon(Icons.delete_forever_rounded, size: 27),
        label: Text(
          AppText.t(context, "ऐप हटाएँ"),
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // TECHNICAL DETAILS
  // ------------------------------------------------------------

  Widget _moreInformation(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 18),
        leading: const Icon(Icons.info_outline_rounded),
        title: Text(
          AppText.t(context, AppText.t(context, "अधिक जानकारी देखें")),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
        children: [
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: Text(AppText.t(context, "पैकेज का नाम")),
            subtitle: Text(app.packageName),
          ),

          ListTile(
            leading: const Icon(Icons.update_rounded),
            title: Text(AppText.t(context, "संस्करण")),
            subtitle: Text("${app.versionName} (${app.versionCode})"),
          ),

          ListTile(
            leading: const Icon(Icons.storefront_outlined),
            title: Text(
              AppText.t(context, AppText.t(context, "कहाँ से जोड़ा गया")),
            ),
            subtitle: Text(app.installerName),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppText.t(context, "ऐप की जानकारी"),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
          children: [
            _appHeader(context),

            const SizedBox(height: 16),

            _statusCard(context),

            const SizedBox(height: 18),

            _capabilityCard(context),

            const SizedBox(height: 16),

            _fraudRokoAdvice(context),

            const SizedBox(height: 18),

            // SAFE APP: NOTHING HERE
            // OUTSIDE APP: LARGE DELETE BUTTON
            _deleteButton(context),

            if (!app.trustedInstaller) const SizedBox(height: 14),

            _moreInformation(context),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
