import 'package:open_project_time_tracker/modules/task_selection/domain/time_entries_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/models/weekday_hours.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/models/project_hours.dart';

class TimeAggregationService {
  /// Aggregates time entries by weekday (all Mondays, all Tuesdays, etc.)
  static WeekdayHours sumByWeekday(List<TimeEntry> entries) {
    return WeekdayHours(
      monday: _sumWeekdayHours(entries, DateTime.monday),
      tuesday: _sumWeekdayHours(entries, DateTime.tuesday),
      wednesday: _sumWeekdayHours(entries, DateTime.wednesday),
      thursday: _sumWeekdayHours(entries, DateTime.thursday),
      friday: _sumWeekdayHours(entries, DateTime.friday),
      saturday: _sumWeekdayHours(entries, DateTime.saturday),
      sunday: _sumWeekdayHours(entries, DateTime.sunday),
    );
  }

  /// Aggregates time entries by project title
  static List<ProjectHours> sumByProject(List<TimeEntry> entries) {
    final Map<String, Duration> projectTotals = {};
    for (var entry in entries) {
      projectTotals[entry.projectTitle] = 
          (projectTotals[entry.projectTitle] ?? Duration.zero) + entry.hours;
    }
    return projectTotals.entries
        .map((e) => ProjectHours(title: e.key, duration: e.value))
        .toList()
      ..sort((a, b) => b.duration.compareTo(a.duration));
  }

  static Duration _sumWeekdayHours(List<TimeEntry> entries, int weekday) {
    return entries
        .where((entry) => entry.spentOn.weekday == weekday)
        .fold(Duration.zero, (sum, entry) => sum + entry.hours);
  }
}
