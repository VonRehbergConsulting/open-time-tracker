import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iso_duration_parser/iso_duration_parser.dart';
import 'package:open_project_time_tracker/models/network_provider.dart';
import 'package:open_project_time_tracker/models/time_entry.dart';
import 'package:open_project_time_tracker/models/user_data_provider.dart';

class TimeEntriesProvider with ChangeNotifier {
  // Properties

  NetworkProvider? networkProvider;
  UserDataProvider? userDataProvider;

  List<TimeEntry> _items = [];

  List<TimeEntry> get items {
    return [..._items];
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
      final workPackage = links["workPackage"];
      final workPackageTitle = workPackage["title"];

      final hoursString = element["hours"];
      final hours =
          Duration(seconds: IsoDuration.parse(hoursString).toSeconds().round());
      items.add(TimeEntry(
        id: id,
        workPackageSubject: workPackageTitle,
        projectTitle: projectTitle,
        hours: hours,
        comment: commentRaw,
      ));
    });

    return items;
  }

  // Public methods

  void update(
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
    final url = Uri.parse('http://192.168.1.3:8080/api/v3/time_entries')
        .replace(queryParameters: {
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
}
