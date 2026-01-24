import 'package:dio/dio.dart' hide Headers;
import 'package:iso_duration_parser/iso_duration_parser.dart';
import 'package:retrofit/retrofit.dart';

part 'time_entries_api.g.dart';

@RestApi()
abstract class TimeEntriesApi {
  factory TimeEntriesApi(Dio dio) = _TimeEntriesApi;

  @GET('/time_entries')
  Future<TimeEntriesResponse> timeEntries({
    @Query('filters') String? filters,
    @Query('pageSize') int? pageSize,
  });

  @POST('/time_entries')
  @Headers(<String, dynamic>{"Content-Type": "application/json"})
  Future<HttpResponse<dynamic>> createTimeEntry({
    @Body() required Map<String, dynamic> body,
  });

  @PATCH('/time_entries/{id}')
  @Headers(<String, dynamic>{"Content-Type": "application/json"})
  Future<void> updateTimeEntry({
    @Path() required id,
    @Body() required Map<String, dynamic> body,
  });

  @DELETE('/time_entries/{id}')
  Future<void> deleteTimeEntry({@Path() required id});
}

class TimeEntryResponse {
  late int id;
  late String workPackageSubject;
  late String workPackageHref;
  late String projectTitle;
  late String projectHref;
  late Duration hours;
  late String? comment;
  late DateTime updatedAt;
  late DateTime spentOn;

  TimeEntryResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    final commentJson = json["comment"];
    comment = commentJson["raw"];

    final links = json["_links"];
    final project = links["project"];
    projectTitle = project["title"];
    projectHref = project["href"];
    final workPackage = links["workPackage"];
    workPackageSubject = workPackage["title"];
    workPackageHref = workPackage["href"];

    final hoursString = json["hours"];
    hours = Duration(
      seconds: IsoDuration.parse(hoursString).toSeconds().round(),
    );
    if (hours.inSeconds.remainder(60) == 59) {
      hours += const Duration(seconds: 1);
    }
    updatedAt = DateTime.tryParse(json['updatedAt']) ?? DateTime.now();

    spentOn = DateTime.parse(json['spentOn']);
  }
}

class TimeEntriesResponse {
  late List<TimeEntryResponse> timeEntries;

  TimeEntriesResponse.fromJson(Map<String, dynamic> json) {
    List<TimeEntryResponse> items = [];
    final embedded = json['_embedded'];
    final elements = embedded['elements'] as List<dynamic>;
    for (var element in elements) {
      items.add(TimeEntryResponse.fromJson(element));
    }
    timeEntries = items;
  }
}
