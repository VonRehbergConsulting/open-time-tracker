import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/extensions/date_time.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/models/weekday_hours.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/models/project_hours.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/services/time_aggregation_service.dart';

import '../../../../app/ui/bloc/bloc.dart';
import '../../domain/time_entries_repository.dart';

part 'analytics_bloc.freezed.dart';

// Constants
const int _kDefaultPageSize = 100;

@freezed
class AnalyticsState with _$AnalyticsState {
  const factory AnalyticsState.loading() = _Loading;
  const factory AnalyticsState.idle({
    required WeekdayHours weekdayHours,
    required List<ProjectHours> projectHours,
  }) = _Idle;
}

class AnalyticsBloc extends Cubit<AnalyticsState> {
  final TimeEntriesRepository _timeEntriesRepository;

  AnalyticsBloc(
    this._timeEntriesRepository,
  ) : super(const AnalyticsState.loading());

  Future<void> reload() async {
    final date = DateTime.now();
    final items = await _timeEntriesRepository.list(
      userId: 'me',
      startDate: date.thisMonday,
      endDate: date.thisSunday,
      pageSize: _kDefaultPageSize,
    );
    
    emit(
      AnalyticsState.idle(
        weekdayHours: TimeAggregationService.sumByWeekday(items),
        projectHours: TimeAggregationService.sumByProject(items),
      ),
    );
  }
}
