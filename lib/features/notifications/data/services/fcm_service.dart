import 'package:firebase_messaging/firebase_messaging.dart';

class FcmService {
  FcmService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (!_initialized) {
      _initialized = true;

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      final initialMessage = await _messaging.getInitialMessage();

      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      _messaging.onTokenRefresh.listen((_) async {
        await syncPermission();
      });
    }

    await syncPermission();
  }

  static Future<void> syncPermission() async {
    final settings = await _messaging.getNotificationSettings();

    final authorized =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    if (!authorized) {
      return;
    }

    await _messaging.subscribeToTopic('cyber_news');
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    // Foreground notification UI will be added separately.
  }

  static void _handleNotificationTap(RemoteMessage message) {
    final type = message.data['type']?.toString();

    if (type != 'cyber_news') {
      return;
    }

    final newsId = message.data['newsId']?.toString();

    if (newsId == null || newsId.isEmpty) {
      return;
    }

    // Cyber News navigation will be connected through the app navigator.
  }
}
