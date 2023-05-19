import 'package:open_project_time_tracker/app/auth/domain/auth_client_data.dart';

class GraphAuthClientData implements AuthClientData {
  static const _baseUrl =
      'https://login.microsoftonline.com/common/oauth2/v2.0';

  @override
  Future<String?> get clientID async => '';

  @override
  Future<String?> get baseUrl async => _baseUrl;

  @override
  Future<String?> get authEndpoint async => '$_baseUrl/authorize';

  @override
  Future<String?> get tokenEndpoint async => '$_baseUrl/token';

  @override
  Future<String?> get logoutEndpoint async => '$_baseUrl/logout';

  @override
  String get redirectUrl => 'openprojecttimetracker://graph-oauth-callback';

  @override
  List<String> get scopes => [
        'user.read',
        'offline_access',
        'Calendars.ReadWrite',
        'MailboxSettings.Read',
      ];
}
