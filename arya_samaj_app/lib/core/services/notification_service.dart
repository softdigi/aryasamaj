import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import '../router/navigator_key.dart';

/// Top-level handler required by FCM for background messages.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialised before this is called.
  NotificationService._showLocalNotification(message);
}

class NotificationService {
  NotificationService._();

  static final _fcm = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _channelId   = 'arya_samaj_channel';
  static const _channelName = 'Arya Samaj Notifications';

  static Future<void> init() async {
    // ── FCM permission ──────────────────────────────────────────────
    await _fcm.requestPermission(
      alert: true, badge: true, sound: true, announcement: false,
    );

    // ── Android notification channel ────────────────────────────────
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // ── flutter_local_notifications init ────────────────────────────
    const androidInit = AndroidInitializationSettings('@drawable/ic_notification');
    const darwinInit  = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: darwinInit),
    );

    // ── Background message handler ───────────────────────────────────
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // ── Foreground message handler ───────────────────────────────────
    FirebaseMessaging.onMessage.listen(_showLocalNotification);

    // ── Handle tap on notification that opened the app ───────────────
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNavigationFromMessage);

    // ── Handle notification that launched the app from terminated state ──
    final initial = await _fcm.getInitialMessage();
    if (initial != null) _handleNavigationFromMessage(initial);

    // ── iOS foreground presentation ──────────────────────────────────
    if (Platform.isIOS) {
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true,
      );
    }
  }

  static void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          icon: '@drawable/ic_notification',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  static Future<String?> getToken() => _fcm.getToken();

  /// Navigate based on notification payload.
  /// Expected data keys: type (content|event|member), id
  static void _handleNavigationFromMessage(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] as String?;
    final id = data['id'] as String?;

    String? route;
    switch (type) {
      case 'content':
        if (id != null) route = '/contents/$id';
        break;
      case 'event':
        route = '/events';
        break;
      case 'member':
        if (id != null) route = '/members/$id';
        break;
    }

    if (route != null) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        GoRouter.of(context).go(route);
      }
    }
  }
}
