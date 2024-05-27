abstract class LiveActivityManager {
  Future<void> startLiveActivity({
    required Map<String, dynamic> activityModel,
  });

  Future<void> updateLiveActivity({
    required Map<String, dynamic> activityModel,
  });

  Future<void> stopLiveActivity();
}

class LiveActivityModel {
  final int startTimestamp;
  final String title;

  LiveActivityModel({
    required this.startTimestamp,
    required this.title,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'startTimestamp': startTimestamp,
      'title': title,
    };
  }
}
