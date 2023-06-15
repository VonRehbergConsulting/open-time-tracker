abstract class CalendarNotificationsService {
  Future<void> scheduleNotifications(
    String title,
    String body,
  );

  Future<void> removeNotifications();
}
