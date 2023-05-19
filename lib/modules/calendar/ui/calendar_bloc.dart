import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc.dart';

import '../../../app/auth/domain/auth_service.dart';
import '../domain/calendar_repository.dart';

part 'calendar_bloc.freezed.dart';

@freezed
class CalendarBlocState with _$CalendarBlocState {
  const factory CalendarBlocState.idle() = _Idle;
}

class CalendarBloc extends Cubit<CalendarBlocState> {
  AuthService _authService;
  CalendarRepository _calendarRepository;

  CalendarBloc(
    this._authService,
    this._calendarRepository,
  ) : super(const CalendarBlocState.idle());

  Future<void> testGraph() async {
    try {
      await _authService.login();
      final now = DateTime.now();
      final start = DateTime(
        now.year,
        now.month,
        now.day,
      );
      final end = DateTime(
        now.year,
        now.month,
        now.day,
        23,
        59,
      );
      final calendarItems = await _calendarRepository.list(
        start: start,
        end: end,
      );
    } catch (e) {
      print(e);
    }
  }
}
