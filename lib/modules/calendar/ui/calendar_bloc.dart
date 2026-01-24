import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc.dart';
import 'package:open_project_time_tracker/modules/calendar/domain/calendar_connection_service.dart';

part 'calendar_bloc.freezed.dart';

@freezed
class CalendarBlocState with _$CalendarBlocState {
  const factory CalendarBlocState.loading() = _Loading;
  const factory CalendarBlocState.landing() = _Landing;
  const factory CalendarBlocState.calendar() = _Calendar;
}

class CalendarBloc extends Cubit<CalendarBlocState> {
  final CalendarConnectionService _calendarConnectionService;

  StreamSubscription? _connectionSubscription;

  CalendarBloc(this._calendarConnectionService)
    : super(const CalendarBlocState.loading());

  Future<void> init() async {
    await _connectionSubscription?.cancel();
    _connectionSubscription = _calendarConnectionService
        .observeConnectionState()
        .listen(_onConnectionStateChanged, onError: addError);
  }

  void _onConnectionStateChanged(bool isConnected) {
    if (isConnected) {
      emit(const CalendarBlocState.calendar());
    } else {
      emit(const CalendarBlocState.landing());
    }
  }

  @override
  Future<void> close() async {
    await _connectionSubscription?.cancel();
    return super.close();
  }

  Future<void> authorize() async {
    await _calendarConnectionService.connect();
  }

  Future<void> unauthorize() async {
    await _calendarConnectionService.disconnect();
  }
}
