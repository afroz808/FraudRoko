import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/localization/app_text.dart';
import '../../../../core/analytics/analytics_service.dart';

class LinkScanScreen extends StatefulWidget {
  const LinkScanScreen({super.key});

  @override
  State<LinkScanScreen> createState() => _LinkScanScreenState();
}

class _LinkScanScreenState extends State<LinkScanScreen> {
  final TextEditingController _linkController = TextEditingController();

  bool _isChecking = false;
  double _scanProgress = 0.0;
  int _scanPhase = 0;
  String? _scannedUrl;
  String? _scanVerdict;
  bool? _scanMalicious;

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _checkLink() async {
    final link = _linkController.text.trim();

    if (link.isEmpty) {
      _showMessage(AppText.t(context, 'Please enter a link'));
      return;
    }

    final uri = Uri.tryParse(link);

    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      _showMessage(AppText.t(context, 'Invalid link'));
      return;
    }

    setState(() {
      _isChecking = true;
      _scanProgress = 0.0;
      _scanPhase = 0;
      _scannedUrl = null;
      _scanVerdict = null;
      _scanMalicious = null;
    });

    _startScanProgress();

    const workerUrl =
        'https://fraudroko-link-scanner.fraudroko-link-check.workers.dev';

    try {
      final submitResponse = await http
          .post(
            Uri.parse(workerUrl),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'url': link}),
          )
          .timeout(const Duration(seconds: 20));

      if (submitResponse.statusCode != 200) {
        throw Exception('Scan submission failed');
      }

      final submitData =
          jsonDecode(submitResponse.body) as Map<String, dynamic>;

      final scanId = submitData['scanId'];

      if (submitData['success'] != true || scanId is! String) {
        throw Exception('Invalid scan response');
      }

      Map<String, dynamic>? resultData;

      for (var attempt = 0; attempt < 12; attempt++) {
        await Future<void>.delayed(const Duration(seconds: 2));

        final resultResponse = await http
            .get(Uri.parse('$workerUrl/result/$scanId'))
            .timeout(const Duration(seconds: 15));

        if (resultResponse.statusCode != 200) {
          continue;
        }

        final data = jsonDecode(resultResponse.body) as Map<String, dynamic>;

        if (data['success'] == true && data['status'] == 'finished') {
          resultData = data;
          break;
        }
      }

      if (!mounted) return;

      setState(() {
        _isChecking = false;
      });

      if (resultData == null) {
        _showMessage(AppText.t(context, 'Link could not be checked'));
        return;
      }

      final verdict = resultData['verdict']?.toString();
      final malicious = resultData['malicious'] == true;

      setState(() {
        _scannedUrl = link;
        _scanVerdict = verdict;
        _scanMalicious = malicious;
      });

      await AnalyticsService.instance.logLinkScan();
    } on TimeoutException {
      if (!mounted) return;

      setState(() {
        _isChecking = false;
      });

      _showMessage(AppText.t(context, 'Please try again later.'));
    } catch (error) {
      debugPrint('Link scan error: $error');

      if (!mounted) return;

      setState(() {
        _isChecking = false;
      });

      _showMessage(AppText.t(context, 'Please try again later.'));
    }
  }

  Widget _buildScanResultCard(BuildContext context) {
    final isDanger = _scanVerdict == 'danger' || _scanMalicious == true;

    final title = isDanger
        ? AppText.t(context, 'Warning! This link looks dangerous')
        : AppText.t(context, 'Link Looks Safe');

    final description = isDanger
        ? AppText.t(context, "Don't open it now.")
        : AppText.t(context, 'Our check found no known danger.');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: isDanger ? const Color(0xfffff1f2) : const Color(0xffEAF8F0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDanger ? const Color(0xfffecdd3) : const Color(0xffccebd8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isDanger
                      ? const Color(0xffffe4e6)
                      : const Color(0xffdcfce7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isDanger
                      ? Icons.warning_rounded
                      : Icons.verified_user_rounded,
                  color: isDanger
                      ? const Color(0xffdc2626)
                      : const Color(0xff16a34a),
                  size: 27,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isDanger
                            ? const Color(0xffb91c1c)
                            : const Color(0xff15803d),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: TextStyle(
                        color: isDanger
                            ? const Color(0xff7f1d1d)
                            : const Color(0xff166534),
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            AppText.t(context, 'Scanned Link'),
            style: const TextStyle(
              color: Color(0xff64748B),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _scannedUrl ?? '',
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xff334155),
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 14),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isDanger ? Icons.block_rounded : Icons.info_outline_rounded,
                color: isDanger
                    ? const Color(0xffdc2626)
                    : const Color(0xff15803d),
                size: 19,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isDanger
                      ? AppText.t(context, "Don't open it now.")
                      : AppText.t(context, 'Our check found no known danger.'),
                  style: TextStyle(
                    color: isDanger
                        ? const Color(0xff7f1d1d)
                        : const Color(0xff166534),
                    fontSize: 12.5,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _startScanProgress() async {
    const phases = <int>[1, 2, 3, 4];

    for (final phase in phases) {
      if (!mounted || !_isChecking) return;

      setState(() {
        _scanPhase = phase;
      });

      final target = phase * 0.20;

      while (mounted && _isChecking && _scanProgress < target) {
        await Future<void>.delayed(const Duration(milliseconds: 120));

        if (!mounted || !_isChecking) return;

        setState(() {
          _scanProgress = (_scanProgress + 0.01).clamp(0.0, target);
        });
      }

      await Future<void>.delayed(const Duration(milliseconds: 450));
    }

    while (mounted && _isChecking && _scanProgress < 0.90) {
      await Future<void>.delayed(const Duration(milliseconds: 120));

      if (!mounted || !_isChecking) return;

      setState(() {
        _scanProgress = (_scanProgress + 0.005).clamp(0.0, 0.90);
      });
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xffF4F8FF),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xff111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppText.t(context, 'Link Scan'),
          style: TextStyle(
            color: Color(0xff111827),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xffE2EAF5)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff1565FF).withValues(alpha: 0.05),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xffEAF2FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.link_rounded,
                        color: Color(0xff1565FF),
                        size: 34,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      AppText.t(context, 'Check a Link'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xff101828),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      AppText.t(context, 'Paste a link to check it'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xff64748B),
                        fontSize: 14,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 22),

                    TextField(
                      controller: _linkController,
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _checkLink(),
                      decoration: InputDecoration(
                        hintText: AppText.t(context, 'Paste your link here'),
                        hintStyle: const TextStyle(
                          color: Color(0xff94A3B8),
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.link_rounded,
                          color: Color(0xff64748B),
                        ),
                        suffixIcon: _linkController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear_rounded,
                                  color: Color(0xff64748B),
                                ),
                                onPressed: () {
                                  _linkController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: const Color(0xffF7FAFF),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 15,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Color(0xffDCE6F3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Color(0xffDCE6F3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Color(0xff1565FF),
                            width: 1.5,
                          ),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isChecking ? null : _checkLink,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff1565FF),
                          disabledBackgroundColor: const Color(0xffAFC8F8),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _isChecking
                              ? Column(
                                  key: const ValueKey('loading'),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          width: 17,
                                          height: 17,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 9),
                                        Text(
                                          '${(_scanProgress * 100).round()}%',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            _scanPhase == 1
                                                ? 'Checking link...'
                                                : _scanPhase == 2
                                                ? 'Analyzing page...'
                                                : _scanPhase == 3
                                                ? 'Checking security signals...'
                                                : 'Preparing result...',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: _scanProgress,
                                        minHeight: 3,
                                        backgroundColor: Colors.white
                                            .withValues(alpha: 0.25),
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  key: const ValueKey('button'),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.shield_rounded, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      AppText.t(context, 'Check Link'),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Icon(Icons.arrow_forward_rounded, size: 19),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (_scannedUrl != null &&
                  _scanVerdict != null &&
                  _scanMalicious != null) ...[
                const SizedBox(height: 14),
                _buildScanResultCard(context),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
