import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/extensions/date_time.dart';

import '../../../../app/ui/bloc/bloc.dart';
import '../../domain/time_entries_repository.dart';

part 'analytics_bloc.freezed.dart';

class DailyHours {
  final Duration monday;
  final Duration tuesday;
  final Duration wednesday;
  final Duration thursday;
  final Duration friday;
  final Duration saturday;
  final Duration sunday;

  bool get isEmpty {
    return monday.inMinutes == 0 &&
        tuesday.inMinutes == 0 &&
        wednesday.inMinutes == 0 &&
        thursday.inMinutes == 0 &&
        friday.inMinutes == 0 &&
        saturday.inMinutes == 0 &&
        sunday.inMinutes == 0;
  }

  DailyHours({
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
  });
}

class ProjectsHours {
  final String title;
  final Duration duration;

  ProjectsHours({
    required this.title,
    required this.duration,
  });
}

@freezed
class AnaliticsState with _$AnaliticsState {
  const factory AnaliticsState.loading() = _Loading;
  const factory AnaliticsState.idle({
    required DailyHours dailyHours,
    required List<ProjectsHours> projectsHours,
  }) = _Idle;
}

class AnalyticsBloc extends Cubit<AnaliticsState> {
  final TimeEntriesRepository _timeEntriesRepository;

  AnalyticsBloc(
    this._timeEntriesRepository,
  ) : super(const AnaliticsState.loading());

  Future<void> reload() async {
    final date = DateTime.now();
    final items = await _timeEntriesRepository.list(
      userId: 'me',
      startDate: date.thisMonday,
      endDate: date.thisSunday,
      pageSize: 100,
    );
    emit(
      AnaliticsState.idle(
        dailyHours: _getDailyHours(items),
        projectsHours: _getProjectHours(items),
      ),
    );
  }

  DailyHours _getDailyHours(List<TimeEntry> items) {
    final date = DateTime.now();
    return DailyHours(
      monday: _sumDayDuration(items, date.thisMonday),
      tuesday: _sumDayDuration(items, date.thisTuesday),
      wednesday: _sumDayDuration(items, date.thisWednesday),
      thursday: _sumDayDuration(items, date.thisThursday),
      friday: _sumDayDuration(items, date.thisFriday),
      saturday: _sumDayDuration(items, date.thisSaturday),
      sunday: _sumDayDuration(items, date.thisSunday),
    );
  }

  Duration _sumDayDuration(
    List<TimeEntry> items,
    DateTime date,
  ) {
    Duration result = Duration.zero;
    items
        .where((element) => element.spentOn.isSameDate(date))
        .toList()
        .forEach((element) {
      result += element.hours;
    });
    return result;
  }

  List<ProjectsHours> _getProjectHours(List<TimeEntry> items) {
    List<ProjectsHours> result = [];
    final projects = items.map((item) => item.projectTitle).toSet();
    for (var project in projects) {
      result.add(
        ProjectsHours(
          title: project,
          duration: _sumProjectDuration(items, project),
        ),
      );
    }
    return result;
  }

  Duration _sumProjectDuration(
    List<TimeEntry> items,
    String project,
  ) {
    Duration result = Duration.zero;
    items
        .where((element) => element.projectTitle == project)
        .toList()
        .forEach((element) {
      result += element.hours;
    });
    return result;
  }
}
