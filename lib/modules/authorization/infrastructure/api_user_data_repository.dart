import 'package:open_project_time_tracker/modules/authorization/domain/user_data_repository.dart';
import 'package:open_project_time_tracker/modules/authorization/infrastructure/user_data_api.dart';

class ApiUserDataRepository implements UserDataRepository {
  final UserDataApi _restApi;
  UserData? _cachedUserData;

  ApiUserDataRepository(this._restApi);

  Future<UserData> _getUserData() async {
    if (_cachedUserData != null) {
      return _cachedUserData!;
    }
    _cachedUserData = await _restApi.getUserData();
    return _cachedUserData!;
  }

  void clearCache() {
    _cachedUserData = null;
  }

  @override
  Future<int> userId() async {
    final userData = await _getUserData();
    return userData.id;
  }

  @override
  Future<String> userName() async {
    final userData = await _getUserData();
    return userData.name;
  }
}
