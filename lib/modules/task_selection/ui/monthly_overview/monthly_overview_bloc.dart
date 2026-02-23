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

@freezed
class MonthlyOverviewState with _$MonthlyOverviewState {
  factory MonthlyOverviewState.loading({@Default(ViewMode.monthly) ViewMode viewMode}) = _Loading;
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

  MonthlyOverviewBloc(
    this._timeEntriesRepository,
    this._userDataRepository,
  ) : super(MonthlyOverviewState.loading());

  void toggleViewMode(ViewMode mode) {
    _viewMode = mode;
    state.maybeWhen(
      loaded: (year, month, dailyHours, weeklyHours, weekdayHours, projectHours, _) {
        emit(MonthlyOverviewState.loaded(
          year: year,
          month: month,
          dailyHours: dailyHours,
          weeklyHours: weeklyHours,
          weekdayHours: weekdayHours,
          projectHours: projectHours,
          viewMode: mode,
        ));
      },
      orElse: () {},
    );
  }

  Future<void> reload() async {
    await _loadMonth(_currentYear, _currentMonth);
  }

  Future<void> changeMonth(int year, int month) async {
    _currentYear = year;
    _currentMonth = month;
    await _loadMonth(year, month);
  }

  Future<void> _loadMonth(int year, int month) async {
    emit(MonthlyOverviewState.loading(viewMode: _viewMode));

    try {
      final userId = await _userDataRepository.userId();

      // Get first and last day of the month
      final firstDay = DateTime(year, month, 1);
      final lastDay = DateTime(year, month + 1, 0);

      // Fetch all time entries for the month
      final timeEntries = await _timeEntriesRepository.list(
        userId: userId.toString(),
        startDate: firstDay,
        endDate: lastDay,
        fetchAll: true,
      );

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

      // Calculate weekday hours and project hours using shared service
      final weekdayHours = TimeAggregationService.sumByWeekday(timeEntries);
      final projectHours = TimeAggregationService.sumByProject(timeEntries);

      emit(MonthlyOverviewState.loaded(
        year: year,
        month: month,
        dailyHours: dailyHours,
        weeklyHours: weeklyHours,
        weekdayHours: weekdayHours,
        projectHours: projectHours,
        viewMode: _viewMode,
      ));
    } on DioException {
      // Network error - emit empty state so UI can display gracefully
      emit(MonthlyOverviewState.loaded(
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
      ));
    } catch (e) {
      // Other errors - emit empty state so UI can display gracefully
      emit(MonthlyOverviewState.loaded(
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
      ));
    }
  }
}

