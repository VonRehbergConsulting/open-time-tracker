import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_service.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc.dart';
import 'package:open_project_time_tracker/modules/authorization/domain/user_data_repository.dart';
import 'package:open_project_time_tracker/modules/authorization/infrastructure/api_user_data_repository.dart';
import 'package:open_project_time_tracker/modules/calendar/domain/calendar_connection_service.dart';
import 'package:open_project_time_tracker/modules/calendar/domain/calendar_notifications_service.dart';

part 'profile_bloc.freezed.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState.idle({
    required bool isCalendarConnected,
    String? userName,
  }) = _Idle;
}

@freezed
class ProfileEffect with _$ProfileEffect {
  const factory ProfileEffect.logout() = _Logout;
}

class ProfileBloc extends EffectCubit<ProfileState, ProfileEffect> {
  final AuthService _authService;
  final CalendarNotificationsService _calendarNotificationsService;
  final UserDataRepository _userDataRepository;
  final CalendarConnectionService _calendarConnectionService;

  StreamSubscription? _connectionSubscription;

  ProfileBloc(
    this._authService,
    this._calendarNotificationsService,
    this._userDataRepository,
    this._calendarConnectionService,
  ) : super(const ProfileState.idle(isCalendarConnected: false)) {
    _init();
  }

  Future<void> _init() async {
    await _connectionSubscription?.cancel();
    _connectionSubscription = _calendarConnectionService
        .observeConnectionState()
        .listen(_onConnectionStateChanged, onError: addError);

    // Fetch user name
    try {
      final name = await _userDataRepository.userName();
      emit(state.copyWith(userName: name));
    } catch (e) {
      print('Error fetching user name: $e');
    }
  }

  void _onConnectionStateChanged(bool isConnected) {
    emit(state.copyWith(isCalendarConnected: isConnected));
  }

  @override
  Future<void> close() async {
    await _connectionSubscription?.cancel();
    return super.close();
  }

  Future<void> connectCalendar() async {
    await _calendarConnectionService.connect();
  }

  Future<void> disconnectCalendar() async {
    await _calendarConnectionService.disconnect();
  }

  Future<void> logout() async {
    await Future.wait([
      _calendarNotificationsService.removeNotifications(),
      _calendarConnectionService.disconnect(),
    ]);
    // Clear user data cache before logging out
    final repository = _userDataRepository;
    if (repository is ApiUserDataRepository) {
      repository.clearCache();
    }
    await _authService.logout();
    emitEffect(const ProfileEffect.logout());
  }
}
