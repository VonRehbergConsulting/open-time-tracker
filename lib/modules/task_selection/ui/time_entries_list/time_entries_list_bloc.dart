import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_client.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc.dart';
import 'package:open_project_time_tracker/modules/authorization/domain/user_data_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/settings_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/time_entries_repository.dart';

part 'time_entries_list_bloc.freezed.dart';

@freezed
class TimeEntriesListState with _$TimeEntriesListState {
  const factory TimeEntriesListState.loading() = _Loading;
  const factory TimeEntriesListState.idle({
    required List<TimeEntry> timeEntries,
    required Duration workingHours,
    required Duration totalDuration,
  }) = _Idle;
}

class TimeEntriesListBloc extends Cubit<TimeEntriesListState> {
  TimeEntriesRepository _timeEntriesRepository;
  UserDataRepository _userDataRepository;
  SettingsRepository _settingsRepository;
  AuthClient _authClient;

  List<TimeEntry> items = [];
  Duration workingHours = Duration(hours: 0);
  Duration totalDuration = Duration(hours: 0);

  TimeEntriesListBloc(
    this._timeEntriesRepository,
    this._userDataRepository,
    this._settingsRepository,
    this._authClient,
  ) : super(const TimeEntriesListState.loading());

  Future<void> reload() async {
    try {
      items = await _timeEntriesRepository.list(
        userId: _userDataRepository.userID,
        date: DateTime.now(),
      );
      workingHours = await _settingsRepository.workingHours;
      totalDuration = const Duration();
      for (var element in items) {
        totalDuration += element.hours;
      }
      emit(TimeEntriesListState.idle(
        workingHours: workingHours,
        timeEntries: items,
        totalDuration: totalDuration,
      ));
    } catch (e) {
      // TODO: show error
    }
  }

  Future<void> updateWorkingHours(Duration value) async {
    await _settingsRepository.setWorkingHours(value);
    workingHours = value;
    emit(TimeEntriesListState.idle(
      workingHours: workingHours,
      timeEntries: items,
      totalDuration: totalDuration,
    ));
  }

  Future<void> unauthorize() async {
    await _authClient.invalidateTokens();
  }
}
