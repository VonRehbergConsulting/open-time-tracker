abstract class LiveActivityManager {
  Future<void> startLiveActivity({required Map<String, dynamic> activityModel});

  Future<void> updateLiveActivity(
      {required Map<String, dynamic> activityModel});

  Future<void> stopLiveActivity();
}

class LiveActivityModel {
  final int elapsedSeconds;
  final String title;

  LiveActivityModel({
    required this.elapsedSeconds,
    required this.title,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'elapsedSeconds': elapsedSeconds,
      'title': title,
    };
  }
}
