// ignore_for_file: invalid_annotation_target

import 'package:dio/dio.dart' hide Headers;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/app/api/graph_api_response.dart';
import 'package:retrofit/retrofit.dart';

part 'graph_calendar_api.g.dart';
part 'graph_calendar_api.freezed.dart';

@RestApi()
abstract class GraphCalendarApi {
  factory GraphCalendarApi(Dio dio) = _GraphCalendarApi;

  @Headers({"Content-type": "application/json"})
  @POST('/v1.0/me/calendar/getSchedule')
  Future<GraphApiListResponse<GraphScheduleResponse>> getSchedule({
    @Body() required GetScheduleRequestBody body,
  });
}

class GetScheduleRequestBody {
  List<String> names;
  String timeZone;
  DateTime startTime;
  DateTime endTime;

  GetScheduleRequestBody({
    required this.names,
    required this.timeZone,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toJson() => {
        'schedules': names,
        'startTime': {
          'dateTime': startTime.toIso8601String(),
          'timeZone': timeZone,
        },
        'endTime': {
          'dateTime': endTime.toIso8601String(),
          'timeZone': timeZone,
        },
      };
}

@freezed
class GraphScheduleResponse with _$GraphScheduleResponse {
  @JsonSerializable(explicitToJson: true)
  const factory GraphScheduleResponse({
    @JsonKey(name: 'scheduleItems')
        required List<GraphScheduleResponseItem> items,
  }) = _GraphScheduleResponse;

  factory GraphScheduleResponse.fromJson(Map<String, dynamic> json) =>
      _$GraphScheduleResponseFromJson(json);
}

@freezed
class GraphScheduleResponseItem with _$GraphScheduleResponseItem {
  @JsonSerializable(explicitToJson: true)
  const factory GraphScheduleResponseItem({
    @JsonKey(name: 'isRecurring') required bool isRecurring,
    @JsonKey(name: 'isReminderSet') required bool isReminderSet,
    @JsonKey(name: 'start') required GraphDateTime start,
    @JsonKey(name: 'end') required GraphDateTime end,
    @JsonKey(name: 'subject') required String subject,
  }) = _GraphScheduleResponseItem;

  factory GraphScheduleResponseItem.fromJson(Map<String, dynamic> json) =>
      _$GraphScheduleResponseItemFromJson(json);
}

@freezed
class GraphDateTime with _$GraphDateTime {
  @JsonSerializable(explicitToJson: true)
  const factory GraphDateTime({
    @JsonKey(name: 'dateTime') required String dateTime,
    @JsonKey(name: 'timeZone') required String timeZone,
  }) = _GraphDateTime;

  factory GraphDateTime.fromJson(Map<String, dynamic> json) =>
      _$GraphDateTimeFromJson(json);
}
