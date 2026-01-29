import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../main.dart';
import '../view/splash_screen.dart';

class NotificationService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // Initialize
  Future<void> initNotification() async {
    if (_isInitialized) return; // prevent re-initialization

    // init timezone handling
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    const initSettingsAndroid = AndroidInitializationSettings('@mipmap/launcher_icon');
    const initSettings = InitializationSettings(android: initSettingsAndroid);

    try {
      // Initialize the plugin
      await notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          handleNotificationTap(response.payload);
        },
      );
      print("NotificationService: Initialization successful.");

      // Request permissions (Android 13+)
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
      notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.requestExactAlarmsPermission();

      _isInitialized = true;
    } catch (e) {
      print("NotificationService: Initialization failed - $e");
    }
  }

  void handleNotificationTap(String? payload) {
    int? notifId = int.tryParse(payload ?? '');

    // Push splash screen and pass arguments
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => SplashScreen(
          fromNotification: true,
          notificationId: notifId,
        ),
      ),
          (route) => false,
    );
  }

  // Notification detail setup
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_channel_id',
        'Daily Notifications',
        channelDescription: 'Daily Notification Channel',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
  }

  // Schedule a notification at a specific time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required String payload
  }) async {
    // Get the current date/time in device's local timezone
    final now = tz.TZDateTime.now(tz.local);

    // Create a date/time for today at the specified hour/min
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    // Schedule the notification
    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails(),
      payload: payload,

      // iOS specific: use exact time specified (vs relative time)
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,

      // Android specific: Allow notification while device is in low-power mode
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,

      // Make notification repeat DAILY at the same time
      matchDateTimeComponents: DateTimeComponents.time,
    );
    // Debug print to confirm scheduling
    print("Notification scheduled: ID=$id, Title='$title', Time=$hour:$minute");
  }

  // Cancel notification by ID
  Future<void> cancelTreatmentNotification(int id) async {
    try {
      await notificationsPlugin.cancel(id);
      print("Cancelled notification for timeline ID: $id");
    } catch (e) {
      print("Error cancelling notification ID $id: $e");
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
  }

  // NEW: Simple Instant Notification for Pokes
  Future<void> showInstantNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'poke_channel_id', // Different ID for pokes
      'Family Pokes',
      channelDescription: 'Notifications from family members',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await notificationsPlugin.show(
      DateTime.now().millisecond, // Unique ID based on time
      title,
      body,
      platformChannelSpecifics,
    );
  }

}
