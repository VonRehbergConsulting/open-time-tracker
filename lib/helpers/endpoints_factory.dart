class EndpointsFactory {
  String baseUrl;

  EndpointsFactory(this.baseUrl);

  String get auth {
    return '$baseUrl/oauth/authorize';
  }

  String get token {
    return '$baseUrl/oauth/token';
  }

  Uri? get userData {
    return Uri.tryParse('$baseUrl/api/v3/users/me');
  }

  Uri? get workPackages {
    return Uri.tryParse('$baseUrl/api/v3/work_packages');
  }

  Uri? get timeEntries {
    return Uri.tryParse('$baseUrl/api/v3/time_entries');
  }

  Uri? timeEntry(int id) {
    return Uri.tryParse('$baseUrl/api/v3/time_entries/${id..toString()}');
  }
}
