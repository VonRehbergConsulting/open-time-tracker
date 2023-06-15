abstract class AuthClientData {
  Future<String?> get clientID;
  Future<String?> get baseUrl;
  Future<String?> get authEndpoint;
  Future<String?> get tokenEndpoint;
  Future<String?> get logoutEndpoint;

  String get redirectUrl;
  List<String> get scopes;
}
