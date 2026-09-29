import '../../../../core/localization/app_text.dart';
import '../../../../core/widgets/app_icon_widget.dart';
import 'package:flutter/material.dart';
import '../../domain/models/security_scan_result.dart';

class SecurityReportScreen extends StatefulWidget {
  final SecurityScanResult result;

  const SecurityReportScreen({super.key, required this.result});

  @override
  State<SecurityReportScreen> createState() => _SecurityReportScreenState();
}

class _SecurityReportScreenState extends State<SecurityReportScreen> {
  SecurityScanResult get result => widget.result;

  @override
  Widget build(BuildContext context) {
    final totalIssues = result.critical.length + result.warning.length;
    final hasIssues = totalIssues > 0;
    final score = result.score.clamp(0, 100);

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xff1565FF)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppText.t(context, "Security Report"),
          style: const TextStyle(
            color: Color(0xff1565FF),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xff1565FF).withValues(alpha: 0.08),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compact score header.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xff1565FF), Color(0xff2D7BFF)],
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff1565FF).withValues(alpha: 0.16),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 92,
                    height: 92,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: score / 100,
                          strokeWidth: 8,
                          backgroundColor: Colors.white.withValues(alpha: 0.18),
                          color: Colors.white,
                        ),
                        Text(
                          "$score%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppText.t(context, "Security Score"),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          score >= 90
                              ? AppText.t(context, "Secure")
                              : score >= 70
                              ? AppText.t(context, "Needs Attention")
                              : AppText.t(context, "Action Needed"),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          hasIssues
                              ? "$totalIssues ${AppText.t(context, "security issues found")}"
                              : AppText.t(
                                  context,
                                  "No important security issues found",
                                ),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Small summary instead of a large report-style statistics area.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xffE8EEF7)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryTile(
                      context,
                      Icons.error_rounded,
                      "${result.critical.length}",
                      "Critical",
                      Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSummaryTile(
                      context,
                      Icons.warning_amber_rounded,
                      "${result.warning.length}",
                      "Warnings",
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSummaryTile(
                      context,
                      Icons.check_circle_rounded,
                      "${result.safe.length}",
                      "Safe",
                      Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            if (hasIssues) ...[
              Text(
                AppText.t(context, "Things to check"),
                style: const TextStyle(
                  color: Color(0xff1F2937),
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),

              ...result.critical.map(
                (issue) => _buildIssueSection(
                  context: context,
                  title: AppText.t(context, "Important security issue"),
                  issues: [issue],
                  color: Colors.red,
                  icon: Icons.priority_high_rounded,
                ),
              ),

              ...result.warning.map(
                (issue) => _buildIssueSection(
                  context: context,
                  title: AppText.t(context, "Check this setting"),
                  issues: [issue],
                  color: Colors.orange,
                  icon: Icons.warning_amber_rounded,
                ),
              ),
            ] else ...[
              _buildAllClearCard(context),
            ],

            if (result.safe.isNotEmpty) ...[
              const SizedBox(height: 14),
              _buildSafeSummary(context),
            ],

            if (result.dangerousApps.isNotEmpty) ...[
              const SizedBox(height: 18),
              _buildDangerousAppsSection(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTile(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            AppText.t(context, label),
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllClearCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: Colors.green,
              size: 26,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              AppText.t(context, "No important security issues found"),
              style: const TextStyle(
                color: Color(0xff1F2937),
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafeSummary(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.green.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "${result.safe.length} ${AppText.t(context, "security checks are okay")}",
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueSection({
    required BuildContext context,
    required String title,
    required List<SecurityIssue> issues,
    required Color color,
    required IconData icon,
  }) {
    final issue = issues.first;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
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
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: issue.titleKey == 'hiddenSuspiciousApp'
                    ? AppIconWidget(
                        packageName: issue.packageName ?? '',
                        size: 42,
                      )
                    : Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppText.t(context, issue.titleKey, issue.args),
                      style: const TextStyle(
                        color: Color(0xff1F2937),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      AppText.t(context, issue.messageKey, issue.args),
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),

                    if (issue.titleKey == 'hiddenSuspiciousApp') ...[
                      Builder(
                        builder: (context) {
                          final name = (issue.appName?.isNotEmpty ?? false)
                              ? issue.appName!
                              : (issue.args['appName'] ?? '');

                          if (name.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              name,
                              style: const TextStyle(
                                color: Color(0xff1F2937),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (issue.canFix) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Text(
                AppText.t(context, issue.actionKey, issue.args),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDangerousAppsSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.apps_rounded,
                  color: Colors.red,
                  size: 22,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  AppText.t(context, "Dangerous Apps Found"),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xff1F2937),
                  ),
                ),
              ),
              Text(
                "${result.dangerousApps.length}",
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...result.dangerousApps.map(
            (app) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xffFAFBFD),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      app.appName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
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
}
