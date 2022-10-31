import 'dart:convert';

import 'package:flutter/material.dart';

import '/models/network_provider.dart';
import '/services/endpoints.dart';

class UserDataProvider with ChangeNotifier {
  // Properties

  NetworkProvider? networkProvider;

  int? _userId;

  int? get userId {
    return _userId;
  }

  // Public methods

  void updateProvider(NetworkProvider provider) {
    networkProvider = provider;
    loadUserId();
  }

  Future<void> loadUserId() async {
    final url = Endpoints.userData;
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
      _userId = null;
      notifyListeners();
    }
  }
}
