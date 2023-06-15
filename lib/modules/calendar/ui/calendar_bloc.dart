import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/app/services/local_notification_service.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc.dart';

import '../../../app/auth/domain/auth_service.dart';

part 'calendar_bloc.freezed.dart';

@freezed
class CalendarBlocState with _$CalendarBlocState {
  const factory CalendarBlocState.loading() = _Loading;
  const factory CalendarBlocState.landing() = _Landing;
  const factory CalendarBlocState.calendar() = _Calendar;
}

class CalendarBloc extends Cubit<CalendarBlocState> {
  final AuthService _authService;
  final LocalNotificationService _localNotificationService;

  StreamSubscription? _graphStateSubscription;

  CalendarBloc(
    this._authService,
    this._localNotificationService,
  ) : super(const CalendarBlocState.loading());

  Future<void> init() async {
    await _graphStateSubscription?.cancel();
    _graphStateSubscription = _authService.observeAuthState().distinct().listen(
          _onAuthServiceStateChanged,
          onError: addError,
        );
  }

  Future<void> _onAuthServiceStateChanged(AuthState state) async {
    state.when(
      undefined: () {
        emit(const CalendarBlocState.loading());
      },
      authenticated: () {
        _localNotificationService.setup();
        emit(const CalendarBlocState.calendar());
      },
      notAuthenticated: () {
        emit(const CalendarBlocState.landing());
      },
    );
  }

  @override
  Future<void> close() async {
    await _graphStateSubscription?.cancel();
    return super.close();
  }

  Future<void> authorize() async {
    try {
      await _authService.login();
    } catch (e) {
      print(e);
    }
  }

  Future<void> unauthorize() async {
    try {
      await _authService.logout();
    } catch (e) {
      print(e);
    }
  }
}
