import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iso_duration_parser/iso_duration_parser.dart';

import '/models/network_provider.dart';
import '/models/time_entry.dart';
import '/models/user_data_provider.dart';
import '/services/duration_formatter.dart';
import '/services/endpoints.dart';

class TimeEntriesProvider with ChangeNotifier {
  // Properties

  NetworkProvider? networkProvider;
  UserDataProvider? userDataProvider;

  List<TimeEntry> _items = [];

  List<TimeEntry> get items {
    return [..._items];
  }

  Duration get totalDuration {
    var total = const Duration();
    _items.forEach((element) => total += element.hours);
    return total;
  }

  // Private methods

  List<TimeEntry> _parseListResponse(Map<String, dynamic> jsonResponse) {
    List<TimeEntry> items = [];
    final embedded = jsonResponse['_embedded'];
    final elements = embedded['elements'] as List<dynamic>;
    elements.forEach((element) {
      final id = element['id'];

      final comment = element["comment"];
      final commentRaw = comment["raw"];

      final links = element["_links"];
      final project = links["project"];
      final projectTitle = project["title"];
      final projectHref = project["href"];
      final workPackage = links["workPackage"];
      final workPackageTitle = workPackage["title"];
      final workPackageHref = workPackage["href"];

      final hoursString = element["hours"];
      final hours =
          Duration(seconds: IsoDuration.parse(hoursString).toSeconds().round());
      items.add(TimeEntry(
        id: id,
        workPackageSubject: workPackageTitle,
        workPackageHref: workPackageHref,
        projectTitle: projectTitle,
        projectHref: projectHref,
        hours: hours,
        comment: commentRaw,
      ));
    });

    return items;
  }

  // Public methods

  void updateProvider(
      NetworkProvider? networkProvider, UserDataProvider? userDataProvider) {
    this.networkProvider = networkProvider;
    this.userDataProvider = userDataProvider;
    notifyListeners();
  }

  Future<void> reload() async {
    final userId = userDataProvider?.userId.toString();
    if (userId == null) {
      return;
    }
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    var filters =
        '[{"user":{"operator":"=","values":["$userId"]}}, {"spent_on":{"operator":"=d","values":["$date"]}}]';
    final url = Endpoints.timeEntries.replace(queryParameters: {
      'filters': filters,
      'pageSize': 40.toString(),
    });
    try {
      final response = await networkProvider?.get(url);
      final parsedResponse = jsonDecode(response!.body) as Map<String, dynamic>;
      _items = _parseListResponse(parsedResponse);
      notifyListeners();
    } catch (error) {
      print('Time entries loading error');
    }
  }

  Future<void> create(
      {required TimeEntry timeEntry, required int userId}) async {
    final body = jsonEncode({
      'user': {'id': userId},
      'workPackage': {'href': timeEntry.workPackageHref},
      'project': {'href': timeEntry.projectHref},
      'spentOn': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'hours': DurationFormatter.toISO8601(timeEntry.hours),
      'comment': {
        'format': 'plain',
        'raw': timeEntry.comment,
      },
    });
    final headers = {"Content-Type": "application/json"};
    final url = Endpoints.timeEntries;
    final response =
        await networkProvider?.post(url, body: body, headers: headers);
    print(jsonDecode(response!.body));
  }

  Future<void> update({required TimeEntry timeEntry}) async {
    final timeEntryId = timeEntry.id;
    if (timeEntryId == null) {
      throw Error();
    }
    final body = jsonEncode({
      'hours': DurationFormatter.toISO8601(timeEntry.hours),
      'comment': {
        'format': 'plain',
        'raw': timeEntry.comment,
      },
    });
    final headers = {"Content-Type": "application/json"};
    final url = Endpoints.timeEntry(timeEntryId);
    final response =
        await networkProvider?.patch(url, body: body, headers: headers);
    print(jsonDecode(response!.body));
  }
}
