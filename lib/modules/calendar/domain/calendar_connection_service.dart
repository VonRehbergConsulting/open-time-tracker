import 'dart:async';

import 'package:open_project_time_tracker/app/auth/domain/auth_service.dart';
import 'package:open_project_time_tracker/app/services/local_notification_service.dart';

/// Service to manage calendar connection state and operations.
/// Encapsulates the logic for connecting/disconnecting calendar
/// and observing authentication state.
class CalendarConnectionService {
  final AuthService _graphAuthService;
  final LocalNotificationService _localNotificationService;

  CalendarConnectionService(
    this._graphAuthService,
    this._localNotificationService,
  );

  /// Observes calendar authentication state changes.
  /// Emits true when connected, false when disconnected.
  Stream<bool> observeConnectionState() {
    return _graphAuthService.observeAuthState().distinct().map((state) {
      return state.when(
        undefined: () => false,
        authenticated: () {
          _localNotificationService.setup();
          return true;
        },
        notAuthenticated: () => false,
      );
    });
  }

  /// Connects the calendar by initiating OAuth login.
  Future<void> connect() async {
    try {
      await _graphAuthService.login();
    } catch (e) {
      // Silently fail - auth errors are handled by auth service
      print('Calendar connection error: $e');
    }
  }

  /// Disconnects the calendar by logging out.
  Future<void> disconnect() async {
    try {
      await _graphAuthService.logout();
    } catch (e) {
      // Silently fail - auth errors are handled by auth service
      print('Calendar disconnection error: $e');
    }
  }
}
