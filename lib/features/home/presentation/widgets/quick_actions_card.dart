import 'package:flutter/material.dart';
import '../../../link_scan/presentation/screens/link_scan_screen.dart';

import '../screens/cyber_news_screen.dart';
import '../../../account_security/presentation/screens/security_tips_screen.dart';
import '../../../cyber_complaint/presentation/screens/cyber_complaint_help_screen.dart';

class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({super.key});

  String _language(BuildContext context) {
    return Localizations.localeOf(context).languageCode;
  }

  String _title(BuildContext context) {
    switch (_language(context)) {
      case 'mr':
        return 'फसवणूक टाळण्यासाठी मदत';
      case 'en':
        return 'Fraud Protection';
      default:
        return 'फ्रॉड से बचने की मदद';
    }
  }

  String _seeAll(BuildContext context) {
    switch (_language(context)) {
      case 'mr':
        return 'सर्व पहा';
      case 'en':
        return 'View all';
      default:
        return 'सभी देखें';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ============================================================
        // SECTION HEADER
        // ============================================================
        Row(
          children: [
            Expanded(
              child: Text(
                _title(context),
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xff111827),
                ),
              ),
            ),

            TextButton(
              onPressed: () {
                // All protection features will be connected here later.
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _seeAll(context),
                    style: const TextStyle(
                      color: Color(0xff1565FF),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xff1565FF),
                    size: 19,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ============================================================
        // FOUR FRAUDROKO ACTIONS
        // ============================================================
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 10.0;
            final columns = constraints.maxWidth >= 600 ? 4 : 2;

            final cardWidth =
                (constraints.maxWidth - ((columns - 1) * spacing)) / columns;

            return GridView.count(
              crossAxisCount: columns,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: cardWidth / 158,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // ========================================================
                // 1. LINK SCAN
                // ========================================================
                _ActionCard(
                  imagePath: 'assets/images/link_scan.png',
                  imageBackground: const Color(0xffEAF2FF),
                  title: _linkTitle(context),
                  subtitle: _linkSubtitle(context),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LinkScanScreen()),
                    );
                  },
                ),

                // ========================================================
                // 2. CYBER NEWS
                // ========================================================
                _ActionCard(
                  imagePath: 'assets/images/cyber_news.png',
                  imageBackground: const Color(0xffFFF7E8),
                  title: _newsTitle(context),
                  subtitle: _newsSubtitle(context),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CyberNewsScreen(),
                      ),
                    );
                  },
                ),

                // ========================================================
                // 3. ACCOUNT SECURITY
                // ========================================================
                _ActionCard(
                  imagePath: 'assets/images/secure_accounts.png',
                  imageBackground: const Color(0xffEAF9F0),
                  title: _accountTitle(context),
                  subtitle: _accountSubtitle(context),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SecurityTipsScreen(),
                      ),
                    );
                  },
                ),

                // ========================================================
                // 4. CYBER COMPLAINT HELP
                // ========================================================
                _ActionCard(
                  imagePath: 'assets/images/cyber_complaint_help.png',
                  imageBackground: const Color(0xffffeeee),
                  title: _complaintTitle(context),
                  subtitle: _complaintSubtitle(context),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CyberComplaintHelpScreen(),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // ========================================================================
  // LINK SCAN
  // ========================================================================

  String _linkTitle(BuildContext context) {
    switch (_language(context)) {
      case 'mr':
        return 'लिंक तपासा';
      case 'en':
        return 'Link Scan';
      default:
        return 'लिंक स्कैन';
    }
  }

  String _linkSubtitle(BuildContext context) {
    switch (_language(context)) {
      case 'mr':
        return 'लिंक सुरक्षित आहे\nका ते तपासा';
      case 'en':
        return 'Check if a link\nis safe';
      default:
        return 'लिंक सुरक्षित है\nया नहीं जाँचें';
    }
  }

  // ========================================================================
  // CYBER NEWS
  // ========================================================================

  String _newsTitle(BuildContext context) {
    switch (_language(context)) {
      case 'mr':
        return 'सायबर बातम्या';
      case 'en':
        return 'Cyber News';
      default:
        return 'साइबर न्यूज़';
    }
  }

  String _newsSubtitle(BuildContext context) {
    switch (_language(context)) {
      case 'mr':
        return 'दररोजच्या सायबर\nधोक्यांची माहिती';
      case 'en':
        return 'Daily cyber\nsecurity updates';
      default:
        return 'रोज की साइबर\nसुरक्षा खबरें';
    }
  }

  // ========================================================================
  // ACCOUNT SECURITY
  // ========================================================================

  String _accountTitle(BuildContext context) {
    switch (_language(context)) {
      case 'mr':
        return 'अकाउंट सुरक्षित ठेवा';
      case 'en':
        return 'Secure Your Accounts';
      default:
        return 'अकाउंट सुरक्षित रखें';
    }
  }

  String _accountSubtitle(BuildContext context) {
    switch (_language(context)) {
      case 'mr':
        return 'तुमचे अकाउंट\nकसे सुरक्षित ठेवावे';
      case 'en':
        return 'Learn to keep\nyour accounts safe';
      default:
        return 'अपने अकाउंट को\nसुरक्षित रखना सीखें';
    }
  }

  // ========================================================================
  // CYBER COMPLAINT HELP
  // ========================================================================

  String _complaintTitle(BuildContext context) {
    switch (_language(context)) {
      case 'mr':
        return 'सायबर तक्रार मदत';
      case 'en':
        return 'Cyber Complaint Help';
      default:
        return 'साइबर शिकायत मदद';
    }
  }

  String _complaintSubtitle(BuildContext context) {
    switch (_language(context)) {
      case 'mr':
        return 'फसवणूक झाल्यास\nकाय करावे';
      case 'en':
        return 'What to do if\nyou face fraud';
      default:
        return 'फ्रॉड होने पर\nक्या करें';
    }
  }

// ==========================================================================
// ACTION CARD
// ==========================================================================

}
class _ActionCard extends StatelessWidget {
  final String imagePath;
  final Color imageBackground;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.imagePath,
    required this.imageBackground,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          constraints: const BoxConstraints(minHeight: 158),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE0E8F2)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x080F2747),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 68,
                height: 68,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: imageBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  cacheWidth: 220,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.image_not_supported_outlined,
                    color: Color(0xFF94A3B8),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  subtitle.replaceAll('\n', ' '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    height: 1.25,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              const Align(
                alignment: Alignment.bottomRight,
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 17,
                  color: Color(0xFF2165B5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
