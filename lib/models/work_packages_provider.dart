import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/models/network_provider.dart';
import 'package:open_project_time_tracker/models/user_data_provider.dart';
import 'package:open_project_time_tracker/models/work_package.dart';
import 'package:open_project_time_tracker/services/endpoints.dart';

class WorkPackagesProvider with ChangeNotifier {
  // Properties

  NetworkProvider? networkProvider;
  UserDataProvider? userDataProvider;

  List<WorkPackage> _items = [];

  List<WorkPackage> get items {
    return [..._items];
  }

  // Private methods

  List<WorkPackage> _parseListResponse(Map<String, dynamic> jsonResponse) {
    List<WorkPackage> items = [];
    final embedded = jsonResponse['_embedded'];
    final elements = embedded['elements'] as List<dynamic>;
    elements.forEach((element) {
      final id = element['id'];

      final subject = element["subject"];

      final links = element["_links"];
      final project = links["project"];
      final projectTitle = project["title"];
      final projectHref = project["href"];

      final priority = links["priority"];
      final priorityTitle = priority['title'];

      final status = links["status"];
      final statusTitle = status['title'];

      items.add(WorkPackage(
          id: id,
          subject: subject,
          projectTitle: projectTitle,
          priority: priorityTitle,
          status: statusTitle));
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
    var filters =
        '[{"assignee":{"operator":"=","values":["$userId"]}}, {"status":{"operator":"!","values":["12"]}}]';
    final url = Uri.parse(Endpoints.workPackages).replace(queryParameters: {
      'filters': filters,
      'pageSize': 40.toString(),
    });
    try {
      final response = await networkProvider?.get(url);
      final parsedResponse = jsonDecode(response!.body) as Map<String, dynamic>;
      _items = _parseListResponse(parsedResponse);
      notifyListeners();
    } catch (error) {
      print('Work packages loading error');
    }
  }
}
