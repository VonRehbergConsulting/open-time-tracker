import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:open_project_time_tracker/modules/authorization/domain/user_data_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/time_entries_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/models/weekday_hours.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/models/project_hours.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/services/time_aggregation_service.dart';

part 'monthly_overview_bloc.freezed.dart';

enum ViewMode { weekly, monthly }

DateTime _startOfWeek(DateTime date) {
  final dateOnly = DateTime(date.year, date.month, date.day);
  return DateTime(
    dateOnly.year,
    dateOnly.month,
    dateOnly.day - (dateOnly.weekday - 1),
  );
}

@freezed
class MonthlyOverviewState with _$MonthlyOverviewState {
  factory MonthlyOverviewState.loading({
    @Default(ViewMode.monthly) ViewMode viewMode,
  }) = _Loading;
  factory MonthlyOverviewState.loaded({
    required int year,
    required int month,
    required Map<int, Duration> dailyHours,
    required Map<int, Duration> weeklyHours,
    required WeekdayHours weekdayHours,
    required List<ProjectHours> projectHours,
    @Default(ViewMode.monthly) ViewMode viewMode,
  }) = _Loaded;
}

@injectable
class MonthlyOverviewBloc extends Cubit<MonthlyOverviewState> {
  final TimeEntriesRepository _timeEntriesRepository;
  final UserDataRepository _userDataRepository;

  int _currentYear = DateTime.now().year;
  int _currentMonth = DateTime.now().month;
  ViewMode _viewMode = ViewMode.monthly;
  DateTime _selectedWeekStart = _startOfWeek(DateTime.now());

  DateTime get selectedWeekStart => _selectedWeekStart;
  DateTime get selectedWeekEnd =>
      _selectedWeekStart.add(const Duration(days: 6));
  bool get canGoToNextWeek {
    final currentWeekStart = _startOfWeek(DateTime.now());
    return _selectedWeekStart.isBefore(currentWeekStart);
  }

  MonthlyOverviewBloc(this._timeEntriesRepository, this._userDataRepository)
    : super(MonthlyOverviewState.loading());

  Future<void> toggleViewMode(ViewMode mode) async {
    if (_viewMode == mode) {
      return;
    }

    _viewMode = mode;
    await _loadMonth(_currentYear, _currentMonth);
  }

  Future<void> reload() async {
    await _loadMonth(_currentYear, _currentMonth);
  }

  Future<void> changeMonth(int year, int month) async {
    _currentYear = year;
    _currentMonth = month;
    await _loadMonth(year, month);
  }

  Future<void> goToPreviousWeek() async {
    _selectedWeekStart = _selectedWeekStart.subtract(const Duration(days: 7));
    await _loadMonth(_currentYear, _currentMonth);
  }

  Future<void> goToNextWeek() async {
    if (!canGoToNextWeek) {
      return;
    }

    _selectedWeekStart = _selectedWeekStart.add(const Duration(days: 7));
    await _loadMonth(_currentYear, _currentMonth);
  }

  Future<void> jumpToCurrentWeek() async {
    final currentWeekStart = _startOfWeek(DateTime.now());
    if (_selectedWeekStart == currentWeekStart) {
      return;
    }

    _selectedWeekStart = currentWeekStart;
    await _loadMonth(_currentYear, _currentMonth);
  }

  Future<void> _loadMonth(int year, int month) async {
    emit(MonthlyOverviewState.loading(viewMode: _viewMode));

    try {
      final userId = await _userDataRepository.userId();
      final userIdString = userId.toString();

      // Get first and last day of the month
      final firstDay = DateTime(year, month, 1);
      final lastDay = DateTime(year, month + 1, 0);
      final selectedWeekEnd = _selectedWeekStart.add(const Duration(days: 6));

      // Fetch month and current-week entries independently
      final result = await Future.wait([
        _timeEntriesRepository.list(
          userId: userIdString,
          startDate: firstDay,
          endDate: lastDay,
          fetchAll: true,
        ),
        _timeEntriesRepository.list(
          userId: userIdString,
          startDate: _selectedWeekStart,
          endDate: selectedWeekEnd,
          fetchAll: true,
        ),
      ]);
      final timeEntries = result[0];
      final selectedWeekEntries = result[1];

      // Calculate daily hours
      final Map<int, Duration> dailyHours = {};
      for (var entry in timeEntries) {
        final day = entry.spentOn.day;
        dailyHours[day] = (dailyHours[day] ?? Duration.zero) + entry.hours;
      }

      // Calculate weekly hours based on calendar rows
      final Map<int, Duration> weeklyHours = {};
      final firstWeekday = firstDay.weekday; // 1=Monday, 7=Sunday
      final daysInMonth = lastDay.day;

      int currentDay = 1;
      int weekRow = 0;

      // Calculate total number of week rows needed
      final totalCells = firstWeekday - 1 + daysInMonth;
      final totalWeeks = (totalCells / 7).ceil();

      for (int week = 0; week < totalWeeks; week++) {
        Duration weekTotal = Duration.zero;

        for (int weekday = 1; weekday <= 7; weekday++) {
          // Skip cells before the first day or after the last day
          if (week == 0 && weekday < firstWeekday) {
            // Empty cell before month starts
            continue;
          }

          if (currentDay > daysInMonth) {
            // Empty cell after month ends
            continue;
          }

          // Add this day's hours to the week total
          weekTotal += dailyHours[currentDay] ?? Duration.zero;
          currentDay++;
        }

        weeklyHours[weekRow] = weekTotal;
        weekRow++;
      }

      // Weekly overview reflects the currently selected week range
      final weekdayHours = TimeAggregationService.sumByWeekday(
        selectedWeekEntries,
      );
      final monthlyProjectHours = TimeAggregationService.sumByProject(
        timeEntries,
      );
      final weeklyProjectHours = TimeAggregationService.sumByProject(
        selectedWeekEntries,
      );

      emit(
        MonthlyOverviewState.loaded(
          year: year,
          month: month,
          dailyHours: dailyHours,
          weeklyHours: weeklyHours,
          weekdayHours: weekdayHours,
          projectHours: _viewMode == ViewMode.weekly
              ? weeklyProjectHours
              : monthlyProjectHours,
          viewMode: _viewMode,
        ),
      );
    } on DioException {
      // Network error - emit empty state so UI can display gracefully
      _emitEmptyState(year: year, month: month);
    } catch (e) {
      // Other errors - emit empty state so UI can display gracefully
      _emitEmptyState(year: year, month: month);
    }
  }

  void _emitEmptyState({required int year, required int month}) {
    emit(
      MonthlyOverviewState.loaded(
        year: year,
        month: month,
        dailyHours: {},
        weeklyHours: {},
        weekdayHours: WeekdayHours(
          monday: Duration.zero,
          tuesday: Duration.zero,
          wednesday: Duration.zero,
          thursday: Duration.zero,
          friday: Duration.zero,
          saturday: Duration.zero,
          sunday: Duration.zero,
        ),
        projectHours: [],
        viewMode: _viewMode,
      ),
    );
  }
}
