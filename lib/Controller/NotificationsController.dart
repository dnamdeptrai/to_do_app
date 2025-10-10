import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:to_do_app/Model/TaskDatabase.dart';

class NotificationsController {
  static final NotificationsController _instance =
      NotificationsController._internal();
  factory NotificationsController() => _instance;
  NotificationsController._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings darwinSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(settings);
  }

  Future<void> requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      await _plugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidImpl?.requestNotificationsPermission();
    }
  }

  Future<void> _scheduleNotification(
      int id, String title, String body, int hour, int minute) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_notification_channel_id',
          'Daily Notifications',
          channelDescription: 'Kênh cho các thông báo hằng ngày',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleDailyNotifications(String userEmail) async {
    await _scheduleNotification(0, 'Chào buổi sáng!',
        'Hãy bắt đầu một ngày mới thật tuyệt vời nhé!', 7, 0);

    await _scheduleNotification(1, 'Công việc buổi chiều',
        'Bạn đã hoàn thành công việc buổi sáng chưa?', 14, 0);

    await _scheduleConditionalNightNotification(userEmail);
  }

  Future<void> _scheduleConditionalNightNotification(String userEmail) async {
    TaskDatabase.setCurrentUser(userEmail);
    final todayDateKey = DateFormat("yyyy-MM-dd").format(DateTime.now());
    final progress =
        await TaskDatabase.instance.getTaskProgressForDate(todayDateKey);

    String title = "Tổng kết ngày";
    String body = (progress == 1.0)
        ? "Tuyệt vời! Bạn đã hoàn thành 100% task rồi 🎉"
        : "Còn vài việc dang dở, cố gắng lên nhé 💪";

    await _scheduleNotification(2, title, body, 22, 0);
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }
}
