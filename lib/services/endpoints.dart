class Endpoints {
  static const _baseUrl = 'http://192.168.178.26:8080';

  static const auth = '$_baseUrl/oauth/authorize';
  static const token = '$_baseUrl/oauth/token';

  static const userData = '$_baseUrl/api/v3/users/me';
  static const timeEntries = '$_baseUrl/api/v3/time_entries';
  static const workPackages = '$_baseUrl/api/v3/work_packages';
}
