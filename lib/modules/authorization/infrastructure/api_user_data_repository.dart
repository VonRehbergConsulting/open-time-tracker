import 'package:open_project_time_tracker/modules/authorization/domain/user_data_repository.dart';
import 'package:open_project_time_tracker/modules/authorization/infrastructure/user_data_api.dart';

class ApiUserDataRepository implements UserDataRepository {
  final UserDataApi _restApi;

  ApiUserDataRepository(this._restApi);

  @override
  Future<int> userId() async {
    // TODO: caching and clearing cache in case of unauthorization
    final response = await _restApi.getUserData();
    return response.id;
  }
}
