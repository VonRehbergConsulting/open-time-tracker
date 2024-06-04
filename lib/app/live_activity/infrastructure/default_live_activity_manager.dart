import 'package:flutter/services.dart';
import 'package:open_project_time_tracker/app/live_activity/domain/live_activity_manager.dart';

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

  @override
  Future<void> startLiveActivity({
    required Map<String, dynamic> activityModel,
  }) async {
    try {
      await _methodChannel.invokeMethod('startLiveActivity', activityModel);
    } catch (e) {
      print("error $e");
    }
  }

  @override
  Future<void> updateLiveActivity({
    required Map<String, dynamic> activityModel,
  }) async {
    try {
      await _methodChannel.invokeMethod('updateLiveActivity', activityModel);
    } catch (e) {
      print("error $e");
    }
  }

  @override
  Future<void> stopLiveActivity() async {
    try {
      await _methodChannel.invokeMethod('stopLiveActivity');
    } catch (e) {
      print("error $e");
    }
  }
}
