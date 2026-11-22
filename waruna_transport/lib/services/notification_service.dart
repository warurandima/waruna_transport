import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/reminder_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _notificationsPlugin.initialize(initSettings);

    // Request permissions for Android 13+
    final androidImpl = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImpl != null) {
      await androidImpl.requestNotificationsPermission();
    }
  }

  Future<void> scheduleReminderNotification(ReminderModel reminder) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        reminder.targetDate.year,
        reminder.targetDate.month,
        reminder.targetDate.day,
        6,
        0,
      );

      // If scheduled time is in the past
      if (scheduledDate.isBefore(now)) {
        // If it's today and past 6:00 AM, trigger in 5 seconds for demonstration / test
        if (reminder.targetDate.year == now.year &&
            reminder.targetDate.month == now.month &&
            reminder.targetDate.day == now.day) {
          scheduledDate = now.add(const Duration(seconds: 5));
        } else {
          // Already passed date, do not schedule
          return;
        }
      }

      const androidDetails = AndroidNotificationDetails(
        'order_reminders_channel',
        'ඇණවුම් මතක් කිරීම් (Order Reminders)',
        channelDescription: 'මතු දිනවලට නියමිත ඇණවුම් සඳහා මතක් කිරීම්',
        importance: Importance.max,
        priority: Priority.high,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _notificationsPlugin.zonedSchedule(
        reminder.id.hashCode,
        'අද දිනට නියමිත ඇණවුම්',
        '${reminder.customerName} - ${reminder.materialType} (${reminder.quantity})',
        scheduledDate,
        notificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }
}
