import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;

class LocalNotificationService {
  final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> setup() async {
    const androidSetting = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSetting = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSetting,
      iOS: iosSetting,
    );

    await _localNotificationsPlugin.initialize(initSettings).then((_) {
      print('Notification setup success');
    }).catchError((Object error) {
      print('Error: $error');
    });
  }

  Future<void> addNotification(
    String title,
    String body,
    DateTime time,
  ) async {
    tzData.initializeTimeZones();
    final scheduleTime = tz.TZDateTime.from(
      time,
      tz.local,
    );

    final androidDetail = AndroidNotificationDetails(
      'channel',
      'channel',
    );
    final iosDetail = DarwinNotificationDetails();
    final noticeDetail = NotificationDetails(
      iOS: iosDetail,
      android: androidDetail,
    );

    final id = 0;

    await _localNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduleTime,
      noticeDetail,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancellAllNotifications() async {
    await _localNotificationsPlugin.cancelAll();
  }
}
