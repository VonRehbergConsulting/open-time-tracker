import 'package:injectable/injectable.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_service.dart';
import 'package:open_project_time_tracker/app/instances/domain/instances_repository.dart';
import 'package:open_project_time_tracker/modules/authorization/domain/user_data_repository.dart';
import 'package:open_project_time_tracker/modules/authorization/infrastructure/api_user_data_repository.dart';
import 'package:open_project_time_tracker/modules/authorization/infrastructure/user_data_api.dart';
import 'package:open_project_time_tracker/modules/authorization/ui/authorization/authorization_bloc.dart';

import '../../app/api/api_client.dart';

@module
abstract class AuthorizationModule {
  @injectable
  UserDataApi userDataApi(@Named('openProject') ApiClient apiClient) =>
      UserDataApi(apiClient.dio);

  @lazySingleton
  UserDataRepository userDataRepository(UserDataApi userDataApi) =>
      ApiUserDataRepository(userDataApi);

  @injectable
  AuthorizationBloc authorizationBloc(
    @Named('openProject') AuthService authService,
    InstancesRepository instancesRepository,
  ) => AuthorizationBloc(authService, instancesRepository);
}

