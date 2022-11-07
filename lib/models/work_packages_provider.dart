import 'dart:convert';

import 'package:flutter/material.dart';

import '/models/network_provider.dart';
import '/models/user_data_provider.dart';
import '/models/work_package.dart';

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
    for (var element in elements) {
      final id = element['id'];

      final subject = element["subject"];

      final links = element["_links"];
      final project = links["project"];
      final projectTitle = project["title"];
      final projectHref = project["href"];

      final self = links["self"];
      final selfHref = self["href"];

      final priority = links["priority"];
      final priorityTitle = priority['title'];

      final status = links["status"];
      final statusTitle = status['title'];

      items.add(WorkPackage(
          id: id,
          subject: subject,
          href: selfHref,
          projectTitle: projectTitle,
          projectHref: projectHref,
          priority: priorityTitle,
          status: statusTitle));
    }
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
    var filters =
        '[{"assignee":{"operator":"=","values":["$userId"]}}, {"status":{"operator":"!","values":["12"]}}]';
    final url = networkProvider?.endpointsFactory.workPackages
        ?.replace(queryParameters: {
      'filters': filters,
      'pageSize': 40.toString(),
    });
    if (url == null) {
      print('Can\'t create url');
      return;
    }
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
