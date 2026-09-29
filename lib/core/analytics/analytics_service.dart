import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logAppOpen() async {
    await _analytics.logAppOpen();
  }

  Future<void> logLogin({String? method}) async {
    await _analytics.logLogin(loginMethod: method ?? 'unknown');
  }

  Future<void> logSignUp({String? method}) async {
    await _analytics.logSignUp(signUpMethod: method ?? 'unknown');
  }

  Future<void> logSecurityScan() async {
    await _analytics.logEvent(name: 'security_scan');
  }

  Future<void> logLinkScan() async {
    await _analytics.logEvent(name: 'link_scan');
  }

  Future<void> logCyberNewsView({String? newsId}) async {
    await _analytics.logEvent(
      name: 'cyber_news_view',
      parameters: {if (newsId != null) 'news_id': newsId},
    );
  }

  Future<void> logScamAlertView({String? alertId}) async {
    await _analytics.logEvent(
      name: 'scam_alert_view',
      parameters: {if (alertId != null) 'alert_id': alertId},
    );
  }

  Future<void> logCourseOpen({String? contentId}) async {
    await _analytics.logEvent(
      name: 'course_open',
      parameters: {if (contentId != null) 'content_id': contentId},
    );
  }

  Future<void> logPremiumOpen() async {
    await _analytics.logEvent(name: 'premium_open');
  }
}
