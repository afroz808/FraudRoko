import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../../../../core/channels/settings_channel.dart';
import '../../../../core/localization/app_text.dart';
import '../../data/datasources/daily_security_report_datasource.dart';

class DailySecurityReportsScreen extends StatefulWidget {
  const DailySecurityReportsScreen({super.key});

  @override
  State<DailySecurityReportsScreen> createState() =>
      _DailySecurityReportsScreenState();
}

class _DailySecurityReportsScreenState
    extends State<DailySecurityReportsScreen> {
  final DailySecurityReportDataSource _dataSource =
      DailySecurityReportDataSource();

  late Future<List<Map<String, dynamic>>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _reportsFuture = _dataSource.getReports();
  }

  void _refresh() {
    setState(() {
      _reportsFuture = _dataSource.getReports();
    });
  }

  int _problemCount(Map<String, dynamic> report) {
    var count = 0;

    if (report['usbDebuggingEnabled'] == true) count++;

    count += _listLength(report['hiddenApps']);
    count += _listLength(report['unknownSourceApps']);
    count += _listLength(report['deviceAdminApps']);

    return count;
  }

  int _listLength(dynamic value) {
    return value is List ? value.length : 0;
  }

  DateTime? _reportDate(Map<String, dynamic> report) {
    final timestamp = report['timestamp'];

    if (timestamp is int && timestamp > 0) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }

    if (timestamp is num && timestamp > 0) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp.toInt());
    }

    return null;
  }

  String _dateText(BuildContext context, DateTime? date) {
    if (date == null) return '';

    return MaterialLocalizations.of(context).formatFullDate(date);
  }

  String _timeText(BuildContext context, DateTime? date) {
    if (date == null) return '';

    return MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(date),
      alwaysUse24HourFormat: false,
    );
  }

  String _reportAge(BuildContext context, DateTime? date) {
    if (date == null) {
      return '';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reportDay = DateTime(date.year, date.month, date.day);
    final difference = today.difference(reportDay).inDays;

    if (difference == 0) {
      return AppText.t(context, 'Today');
    }

    if (difference == 1) {
      return AppText.t(context, 'Yesterday');
    }

    return _dateText(context, date);
  }

  List<Map<String, String>> _details(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map>()
        .map(
          (item) => {
            'packageName': item['packageName']?.toString() ?? '',
            'appName': item['appName']?.toString() ?? '',
          },
        )
        .where(
          (item) =>
              item['packageName']!.isNotEmpty && item['appName']!.isNotEmpty,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppText.t(context, 'dailySecurityReports'),
          style: const TextStyle(
            color: Color(0xff1565FF),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded, color: Color(0xff1565FF)),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorState(onRetry: _refresh);
          }

          final reports = snapshot.data ?? [];

          if (reports.isEmpty) {
            return _EmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              _refresh();
              await _reportsFuture;
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                return _ReportCard(
                  report: reports[index],
                  dateText: _dateText(context, _reportDate(reports[index])),
                  timeText: _timeText(context, _reportDate(reports[index])),
                  ageText: _reportAge(context, _reportDate(reports[index])),
                  problemCount: _problemCount(reports[index]),
                  onTap: () => _openReport(context, reports, index),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _openReport(
    BuildContext context,
    List<Map<String, dynamic>> reports,
    int index,
  ) async {
    // Daily Security Reports are free for all signed-in users.
    // Premium gating applies to unlimited phone scans and premium security
    // features, not to report reading.
    _showReportDetails(context, reports[index]);
  }

  void _showReportDetails(BuildContext context, Map<String, dynamic> report) {
    final problemCount = _problemCount(report);
    final date = _reportDate(report);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.88,
            ),
            decoration: const BoxDecoration(
              color: Color(0xffF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppText.t(context, 'dailySecurityReport'),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ReportHeader(
                          problemCount: problemCount,
                          dateText: _dateText(context, date),
                          timeText: _timeText(context, date),
                        ),
                        const SizedBox(height: 18),
                        if (problemCount == 0)
                          _SafeSummary()
                        else ...[
                          if (report['usbDebuggingEnabled'] == true)
                            _IssueCard(
                              icon: Icons.usb_rounded,
                              title: AppText.t(context, 'usbDebuggingEnabled'),
                              message: AppText.t(context, 'keepDisabled'),
                              critical: true,
                              onFix: () =>
                                  _runAction(context, 'usbDebuggingEnabled'),
                            ),
                          if (report['screenLockEnabled'] != true)
                            _IssueCard(
                              icon: Icons.lock_outline_rounded,
                              title: AppText.t(context, 'screenLockNotEnabled'),
                              message: AppText.t(context, 'setPinOrPattern'),
                              critical: true,
                              onFix: () =>
                                  _runAction(context, 'screenLockNotEnabled'),
                            ),
                          if (report['developerOptionsEnabled'] == true)
                            _IssueCard(
                              icon: Icons.developer_mode_rounded,
                              title: AppText.t(
                                context,
                                'developerOptionsEnabled',
                              ),
                              message: AppText.t(context, 'turnOffIfNotNeeded'),
                              critical: false,
                              onFix: () => _runAction(
                                context,
                                'developerOptionsEnabled',
                              ),
                            ),
                          ..._hiddenAppCards(context, report),
                          ..._unknownSourceCards(context, report),
                          ..._deviceAdminCards(context, report),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _hiddenAppCards(
    BuildContext context,
    Map<String, dynamic> report,
  ) {
    final items = _details(report['hiddenAppDetails']);

    return items.map((item) {
      return _IssueCard(
        icon: Icons.visibility_off_rounded,
        title: AppText.t(context, 'hiddenAppFound'),
        appName: item['appName'],
        message: AppText.t(context, 'hiddenAppFoundMessage'),
        critical: true,
        onFix: () => _openApp(context, item['packageName']!),
      );
    }).toList();
  }

  List<Widget> _unknownSourceCards(
    BuildContext context,
    Map<String, dynamic> report,
  ) {
    final items = _details(report['unknownSourceAppDetails']);

    return items.map((item) {
      return _IssueCard(
        icon: Icons.download_for_offline_outlined,
        title: AppText.t(context, 'unknownSourceAppFound'),
        appName: item['appName'],
        message: AppText.t(context, 'checkRequired'),
        critical: true,
        onFix: () => _openApp(context, item['packageName']!),
      );
    }).toList();
  }

  List<Widget> _deviceAdminCards(
    BuildContext context,
    Map<String, dynamic> report,
  ) {
    final items = _details(report['deviceAdminAppDetails']);

    return items.map((item) {
      return _IssueCard(
        icon: Icons.admin_panel_settings_outlined,
        title: AppText.t(context, 'deviceAdminFound'),
        appName: item['appName'],
        message: AppText.t(context, 'checkRequired'),
        critical: false,
        onFix: () => _runAction(context, 'specialPhoneControl'),
      );
    }).toList();
  }

  Future<void> _openApp(BuildContext context, String packageName) async {
    try {
      await SettingsChannel.openAppDetails(packageName);
    } catch (e) {
      debugPrint('FraudRoko app settings error: $e');
    }
  }

  Future<void> _runAction(BuildContext context, String action) async {
    try {
      switch (action) {
        case 'screenLockNotEnabled':
          await SettingsChannel.openSecuritySettings();
          break;
        case 'usbDebuggingEnabled':
        case 'developerOptionsEnabled':
          await SettingsChannel.openDeveloperOptions();
          break;
        case 'securityUpdateOutdated':
          await SettingsChannel.openSystemUpdate();
          break;
        case 'accessibilityServices':
          await SettingsChannel.openAccessibilitySettings();
          break;
        case 'notificationAccess':
          await SettingsChannel.openNotificationAccessSettings();
          break;
        case 'specialPhoneControl':
          await SettingsChannel.openSecuritySettings();
          break;
      }
    } catch (e) {
      debugPrint('FraudRoko settings error: $e');
    }
  }
}

class _ReportCard extends StatelessWidget {
  final Map<String, dynamic> report;
  final String dateText;
  final String timeText;
  final String ageText;
  final int problemCount;
  final VoidCallback onTap;

  const _ReportCard({
    required this.report,
    required this.dateText,
    required this.timeText,
    required this.ageText,
    required this.problemCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasProblems = problemCount > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: hasProblems
              ? Colors.orange.withValues(alpha: 0.18)
              : Colors.green.withValues(alpha: 0.14),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: hasProblems
                      ? Colors.orange.withValues(alpha: 0.10)
                      : Colors.green.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  hasProblems
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_outline_rounded,
                  color: hasProblems ? Colors.orange : Colors.green,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ageText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      dateText,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      timeText,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    if (hasProblems) ...[
                      const SizedBox(height: 7),
                      Text(
                        '$problemCount ${AppText.t(context, 'checkRequired')}',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 7),
                      Text(
                        AppText.t(context, 'noImportantSecurityProblems'),
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xff1565FF)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportHeader extends StatelessWidget {
  final int problemCount;
  final String dateText;
  final String timeText;

  const _ReportHeader({
    required this.problemCount,
    required this.dateText,
    required this.timeText,
  });

  @override
  Widget build(BuildContext context) {
    final clean = problemCount == 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: clean
            ? Colors.green.withValues(alpha: 0.08)
            : Colors.orange.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                clean
                    ? Icons.verified_user_outlined
                    : Icons.warning_amber_rounded,
                size: 28,
                color: clean ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  clean
                      ? AppText.t(context, 'noImportantSecurityProblems')
                      : AppText.t(context, 'importantProblemFound'),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: clean
                        ? Colors.green.shade800
                        : Colors.orange.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(dateText, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            '${AppText.t(context, 'reportTime')}: $timeText',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _SafeSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 30),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              AppText.t(context, 'noImportantSecurityProblems'),
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IssueCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? appName;
  final String message;
  final bool critical;
  final VoidCallback onFix;

  const _IssueCard({
    required this.icon,
    required this.title,
    this.appName,
    required this.message,
    required this.critical,
    required this.onFix,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = critical ? Colors.red.shade700 : Colors.orange.shade800;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: critical
              ? Colors.red.withValues(alpha: 0.16)
              : Colors.orange.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: critical
                      ? Colors.red.withValues(alpha: 0.09)
                      : Colors.orange.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: critical ? Colors.red : Colors.orange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
              ),
            ],
          ),
          if (appName != null && appName!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xffF8FAFC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                appName!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey.shade700,
              height: 1.4,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: onFix,
              icon: const Icon(Icons.open_in_new_rounded, size: 19),
              label: Text(
                AppText.t(context, 'checkRequired'),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff1565FF),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: const Color(0xff1565FF).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.security_rounded,
                size: 42,
                color: Color(0xff1565FF),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              AppText.t(context, 'noDailySecurityReports'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              AppText.t(context, 'dailyReportsWillAppear'),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: Colors.grey.shade500,
            ),
            const SizedBox(height: 14),
            Text(
              AppText.t(context, 'reportLoadFailed'),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, height: 1.4),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(AppText.t(context, 'checkRequired')),
            ),
          ],
        ),
      ),
    );
  }
}
