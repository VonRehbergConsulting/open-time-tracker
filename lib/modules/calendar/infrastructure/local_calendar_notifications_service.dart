import 'package:open_project_time_tracker/app/services/local_notification_service.dart';
import 'package:open_project_time_tracker/modules/calendar/domain/calendar_notifications_service.dart';

import '../domain/calendar_repository.dart';

class LocalCalendarNotificationsService
    implements CalendarNotificationsService {
  final LocalNotificationService _localNotificationService;
  final CalendarRepository _calendarRepository;

  LocalCalendarNotificationsService(
    this._localNotificationService,
    this._calendarRepository,
  );

  @override
  Future<void> scheduleNotifications(
    String title,
    String body,
  ) async {
    try {
      var now = DateTime.now();
      final start = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour,
      );
      final end = DateTime(
        now.year,
        now.month,
        now.day,
        23,
        59,
      );
      final calendarItems = await _calendarRepository.list(
        start: start,
        end: end,
      );
      now = DateTime.now();
      calendarItems
          .where(
        (element) =>
            element.start.millisecondsSinceEpoch > now.millisecondsSinceEpoch,
      )
          .forEach((item) {
        print('Set notification for ${item.start}');
        _localNotificationService.addNotification(
          title: title,
          body: body,
          time: item.start,
          type: NotificationType.meeting,
        );
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> removeNotifications() async {
    await _localNotificationService.cancellAllNotifications();
    print('Notifications removed');
  }
}
