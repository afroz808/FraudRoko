import 'package:flutter/material.dart';
import 'package:fraudroko_app/features/security/presentation/screens/security_scan_screen.dart';

class PhoneSecurityCard extends StatelessWidget {
  const PhoneSecurityCard({super.key});

  void _openScan(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SecurityScanScreen()),
    );
  }

  String _title(BuildContext context) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'mr':
        return 'तुमच्या फोनमध्ये काही धोका तर नाही ना?';
      case 'en':
        return 'Is there any danger on your phone?';
      default:
        return 'कहीं आपके फोन में कोई खतरा तो नहीं?';
    }
  }

  String _subtitle(BuildContext context) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'mr':
        return 'तुमच्या फोनची सुरक्षा तपासा.';
      case 'en':
        return 'Check your phone security.';
      default:
        return 'अपने फोन की सुरक्षा जाँचें।';
    }
  }

  String _buttonTitle(BuildContext context) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'mr':
        return 'आत्ताच तपासा';
      case 'en':
        return 'Check Now';
      default:
        return 'अभी जाँचें';
    }
  }

  String _lastScanText(BuildContext context) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'mr':
        return 'आखिरी तपासणी: अजून झाली नाही';
      case 'en':
        return 'Last check: Not done yet';
      default:
        return 'आखिरी जाँच: अभी तक नहीं हुई';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD9E7F7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D1565FF),
            blurRadius: 22,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 360;
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: compact ? 94 : 112,
                      height: compact ? 112 : 124,
                      child: Image.asset(
                        'assets/images/phone_security_question.png',
                        fit: BoxFit.contain,
                        cacheWidth: compact ? 260 : 320,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _title(context),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF101828),
                              fontSize: 19,
                              height: 1.16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _subtitle(context),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 13,
                              height: 1.3,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 11),
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton.icon(
                              onPressed: () => _openScan(context),
                              icon: const Icon(Icons.shield_rounded, size: 20),
                              label: Flexible(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        _buttonTitle(context),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.arrow_forward_rounded, size: 19),
                                  ],
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1565FF),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFFAF3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.history_rounded, size: 19, color: Color(0xFF2E7D57)),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          _lastScanText(context),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF2E7D57),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
