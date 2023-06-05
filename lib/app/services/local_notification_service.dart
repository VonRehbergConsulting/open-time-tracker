import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/app/app_router.dart';
import 'package:open_project_time_tracker/app/di/inject.dart';
import 'package:open_project_time_tracker/modules/timer/domain/timer_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

part 'local_notification_service.g.dart';

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin;

  LocalNotificationService(
    this._localNotificationsPlugin,
  );

  static callback(NotificationResponse response) async {
    try {
      if (response.payload == null) {
        throw ErrorDescription('Notification payload is null');
      }
      final payload =
          NotificationPayload.fromJson(jsonDecode(response.payload!));
      switch (payload.type) {
        case NotificationType.meeting:
          AppRouter.showLoading(
            () async {
              await inject<TimerService>().submit();
            },
          );
          break;
        default:
          throw ErrorDescription('Notification type is not provided');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> setup() async {
    const androidSetting = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSetting = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSetting,
      iOS: iosSetting,
    );

    try {
      await _localNotificationsPlugin.initialize(
        initSettings,
        onDidReceiveBackgroundNotificationResponse: callback,
        onDidReceiveNotificationResponse: callback,
      );
      print('Notification setup success');
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> addNotification({
    required String title,
    required String body,
    required DateTime time,
    NotificationType? type,
  }) async {
    tz_data.initializeTimeZones();
    final scheduleTime = tz.TZDateTime.from(
      time,
      tz.local,
    );

    const androidDetail = AndroidNotificationDetails(
      'channel',
      'channel',
    );
    const iosDetail = DarwinNotificationDetails();
    const noticeDetail = NotificationDetails(
      iOS: iosDetail,
      android: androidDetail,
    );

    const id = 0;
    final payload = jsonEncode(
      NotificationPayload(
        type: type,
      ).toJson(),
    );

    await _localNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduleTime,
      noticeDetail,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<void> cancellAllNotifications() async {
    await _localNotificationsPlugin.cancelAll();
  }
}

@JsonSerializable()
class NotificationPayload {
  @JsonKey(name: 'type')
  final NotificationType? type;

  NotificationPayload({
    this.type,
  });

  factory NotificationPayload.fromJson(Map<String, dynamic> json) =>
      _$NotificationPayloadFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationPayloadToJson(this);
}

enum NotificationType {
  meeting,
}
