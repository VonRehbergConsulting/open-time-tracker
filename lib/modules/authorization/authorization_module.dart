import 'package:injectable/injectable.dart';
import 'package:open_project_time_tracker/app/api/rest_api_client.dart';
import 'package:open_project_time_tracker/modules/authorization/domain/user_data_repository.dart';
import 'package:open_project_time_tracker/modules/authorization/infrastructure/api_user_data_repository.dart';
import 'package:open_project_time_tracker/modules/authorization/infrastructure/user_data_api.dart';

import 'ui/authorization_checker/authorization_checker_bloc.dart';

@module
abstract class AuthorizationModule {
  @injectable
  UserDataApi userDataApi(RestApiClient apiClient) =>
      UserDataApi(apiClient.dio);

  @lazySingleton
  UserDataRepository userDataRepository(
    UserDataApi userDataApi,
  ) =>
      ApiUserDataRepository(
        userDataApi,
      );

  @injectable
  AuthorizationCheckerBloc authorizationCheckerBloc(
    UserDataRepository userDataRepository,
  ) =>
      AuthorizationCheckerBloc(
        userDataRepository,
      );
}
