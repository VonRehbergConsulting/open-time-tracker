import '/env/env.dart';

class Endpoints {
  static const _baseUrl = Env.baseUrl;

  static const auth = '$_baseUrl/oauth/authorize';
  static const token = '$_baseUrl/oauth/token';

  static final userData = Uri.parse('$_baseUrl/api/v3/users/me');
  static final workPackages = Uri.parse('$_baseUrl/api/v3/work_packages');

  static final timeEntries = Uri.parse('$_baseUrl/api/v3/time_entries');
  static Uri timeEntry(int id) {
    return Uri.parse('$_baseUrl/api/v3/time_entries/${id..toString()}');
  }
}
