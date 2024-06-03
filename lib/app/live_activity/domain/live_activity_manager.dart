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
  final String subtitle;
  final String tag;

  LiveActivityModel({
    required this.startTimestamp,
    required this.title,
    required this.subtitle,
    required this.tag,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'startTimestamp': startTimestamp,
      'title': title,
      'subtitle': subtitle,
      'tag': tag,
    };
  }
}
