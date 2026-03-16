import 'dart:io';
import 'package:flutter/services.dart';
import 'package:open_project_time_tracker/app/live_activity/domain/live_activity_manager.dart';
import 'package:permission_handler/permission_handler.dart';

class DefaultLiveActivityManager implements LiveActivityManager {
  final String channelKey;
  late final MethodChannel _methodChannel;

  DefaultLiveActivityManager({
    required this.channelKey,
  }) {
    _methodChannel = MethodChannel(
      channelKey,
    );
  }

  Future<bool> _ensureNotificationPermission() async {
    // Only needed for Android 13+ (API 33+)
    if (Platform.isAndroid) {
      var status = await Permission.notification.status;
      if (!status.isGranted) {
        status = await Permission.notification.request();
      }
      return status.isGranted;
    }
    // iOS doesn't need runtime permission for Live Activities
    return true;
  }

  @override
  Future<void> startLiveActivity({
    required Map<String, dynamic> activityModel,
  }) async {
    try {
      // Request notification permission on Android if needed
      if (Platform.isAndroid) {
        final hasPermission = await _ensureNotificationPermission();
        if (!hasPermission) {
          print("[LiveActivity] Notification permission denied - cannot show timer notification");
          return;
        }
      }
      
      await _methodChannel.invokeMethod('startLiveActivity', activityModel);
    } catch (e, stackTrace) {
      print("[LiveActivity] Error starting live activity: $e");
      print("[LiveActivity] Stack trace: $stackTrace");
    }
  }

  @override
  Future<void> updateLiveActivity({
    required Map<String, dynamic> activityModel,
  }) async {
    try {
      await _methodChannel.invokeMethod('updateLiveActivity', activityModel);
    } catch (e, stackTrace) {
      print("[LiveActivity] Error updating: $e");
      print("[LiveActivity] Stack trace: $stackTrace");
    }
  }

  @override
  Future<void> stopLiveActivity() async {
    try {
      await _methodChannel.invokeMethod('stopLiveActivity');
    } catch (e) {
      print("[LiveActivity] Error stopping: $e");
    }
  }
}
