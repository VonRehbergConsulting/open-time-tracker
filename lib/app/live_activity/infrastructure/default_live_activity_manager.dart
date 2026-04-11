import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:open_project_time_tracker/app/live_activity/domain/live_activity_manager.dart';
import 'package:permission_handler/permission_handler.dart';

/// Exception thrown when notification permission is denied
class LiveActivityPermissionException implements Exception {
  final String message;
  LiveActivityPermissionException(this.message);

  @override
  String toString() => message;
}

class DefaultLiveActivityManager implements LiveActivityManager {
  final String channelKey;
  late final MethodChannel _methodChannel;

  DefaultLiveActivityManager({required this.channelKey}) {
    _methodChannel = MethodChannel(channelKey);
  }

  /// Ensure notification permission is granted
  /// Throws LiveActivityPermissionException if permission is denied or permanently denied
  Future<void> _ensureNotificationPermission() async {
    // Only needed for Android 13+ (API 33+)
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      var status = await Permission.notification.status;

      if (status.isPermanentlyDenied) {
        throw LiveActivityPermissionException(
          'Notification permission permanently denied. Please enable it in app settings.',
        );
      }

      if (!status.isGranted) {
        status = await Permission.notification.request();

        if (status.isPermanentlyDenied) {
          throw LiveActivityPermissionException(
            'Notification permission permanently denied. Please enable it in app settings.',
          );
        }

        if (!status.isGranted) {
          throw LiveActivityPermissionException(
            'Notification permission required to show active timer.',
          );
        }
      }
    }
  }

  @override
  Future<void> startLiveActivity({
    required Map<String, dynamic> activityModel,
  }) async {
    // Request notification permission on Android if needed
    await _ensureNotificationPermission();

    await _methodChannel.invokeMethod('startLiveActivity', activityModel);
  }

  @override
  Future<void> updateLiveActivity({
    required Map<String, dynamic> activityModel,
  }) async {
    await _methodChannel.invokeMethod('updateLiveActivity', activityModel);
  }

  @override
  Future<void> stopLiveActivity() async {
    await _methodChannel.invokeMethod('stopLiveActivity');
  }
}
