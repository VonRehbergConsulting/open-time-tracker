import 'package:injectable/injectable.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_service.dart';
import 'package:open_project_time_tracker/app/instances/domain/instance_switcher.dart';
import 'package:open_project_time_tracker/app/instances/domain/instances_repository.dart';
import 'package:open_project_time_tracker/modules/instances/ui/instance_editor/instance_editor_bloc.dart';
import 'package:open_project_time_tracker/modules/instances/ui/instances_list/instances_list_bloc.dart';

@module
abstract class InstancesModule {
  @injectable
  InstancesListBloc instancesListBloc(
    InstancesRepository instancesRepository,
    InstanceSwitcher instanceSwitcher,
  ) => InstancesListBloc(instancesRepository, instanceSwitcher);

  @injectable
  InstanceEditorBloc instanceEditorBloc(
    InstancesRepository instancesRepository,
    @Named('openProject') AuthService authService,
  ) => InstanceEditorBloc(instancesRepository, authService);
}
