import 'package:open_project_time_tracker/modules/authorization/domain/user_data_repository.dart';
import 'package:open_project_time_tracker/modules/authorization/infrastructure/user_data_api.dart';

class ApiUserDataRepository implements UserDataRepository {
  int? _userID;
  @override
  int? get userID {
    return _userID;
  }

  final UserDataApi _restApi;

  ApiUserDataRepository(this._restApi);

  @override
  Future<int?> loadUserID() async {
    final response = await _restApi.getUserData();
    _userID = response.id;
    return _userID;
  }
}
