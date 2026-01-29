import 'package:firebase_messaging/firebase_messaging.dart';
import '../main.dart';
import 'notification_service.dart';

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();
  factory FirebaseMessagingService.instance() => _instance;
  FirebaseMessagingService._internal();

  final NotificationService _notificationService = NotificationService();

  Future<void> init() async {
    // 1. Request Permission
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Initialize your local notification service if not already
    await _notificationService.initNotification();

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print("🔄 FCM Token Refreshed: $newToken");

      // A. Update the global variable
      globalFcmToken = newToken;
    });

    // 3. Listen for Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message received: ${message.notification?.title}');

      if (message.notification != null) {
        // CALL YOUR EXISTING SERVICE
        _notificationService.showInstantNotification(
            message.notification!.title ?? "HeartCare",
            message.notification!.body ?? "New Message"
        );
      }
    });
  }

  // Helper to get token (Call this after login)
  Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }
}