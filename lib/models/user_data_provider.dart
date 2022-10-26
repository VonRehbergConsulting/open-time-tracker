import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/models/network_provider.dart';
import 'package:open_project_time_tracker/services/endpoints.dart';

class UserDataProvider with ChangeNotifier {
  // Properties

  NetworkProvider? networkProvider;

  int? _userId;

  int? get userId {
    return _userId;
  }

  // Public methods

  void update(NetworkProvider provider) {
    networkProvider = provider;
    loadUserId();
  }

  Future<void> loadUserId() async {
    final url = Uri.parse(Endpoints.userData);
    try {
      final response = await networkProvider?.get(url);
      if (response == null) {
        throw Error;
      }
      final id = jsonDecode(response.body)['id'];
      _userId = id;
      notifyListeners();
      print('userId: $id');
    } catch (error) {
      print('Error getting user id');
    }
  }
}
