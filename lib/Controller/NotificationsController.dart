// lib/Service/NotificationService.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:to_do_app/Model/TaskDatabase.dart';

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    tz.initializeTimeZones();
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> requestIOSPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> _scheduleNotification(
    int id,
    String title,
    String body,
    Time time,
  ) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
      time.second,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_notification_channel_id',
          'Daily Notifications',
          channelDescription: 'Kênh cho các thông báo hàng ngày',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: IOSNotificationDetails(),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleDailyNotifications(String userEmail) async {
    await _scheduleNotification(
      0,
      'Chào buổi sáng!',
      'Hãy bắt đầu một ngày mới thật tuyệt vời nhé',
      const Time(7, 0, 0),
    );

    await _scheduleNotification(
      1,
      'Công việc buổi chiều',
      'Bạn đã hoàn thành công việc buổi sáng này chưa?',
      const Time(14, 0, 0),
    );

    await _scheduleConditionalNightNotification(userEmail);
  }

  Future<void> _scheduleConditionalNightNotification(String userEmail) async {
    TaskDatabase.setCurrentUser(userEmail);
    final todayDateKey = DateFormat("yyyy-MM-dd").format(DateTime.now());
    final progress = await TaskDatabase.instance.getTaskProgressForDate(
      todayDateKey,
    );

    String title = "Tổng kết ngày";
    String body;

    if (progress == 1.0) {
      body = "Quá đẳng cấp! Bạn đã hoàn thành 100% task rồi này.";
    } else {
      body = "Còn một vài task chưa hoàn thiện, cố gắng lên nào!";
    }

    await _scheduleNotification(2, title, body, const Time(22, 0, 0));
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
