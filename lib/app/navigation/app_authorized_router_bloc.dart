import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/app/storage/app_state_repository.dart';
import 'package:open_project_time_tracker/modules/timer/domain/timer_repository.dart';

import '../ui/bloc/bloc.dart';

part 'app_authorized_router_bloc.freezed.dart';

@freezed
class AppAuthorizedRouterState with _$AppAuthorizedRouterState {
  factory AppAuthorizedRouterState.initializing() = _Initializing;
  factory AppAuthorizedRouterState.idle({
    required bool isTimerSet,
    required bool isViewingToday,
  }) = _Idle;
}

class AppAuthorizedRouterBloc extends Cubit<AppAuthorizedRouterState> {
  final TimerRepository Function() _getTimerRepository;
  final AppStateRepository Function() _getAppStateRepository;
  StreamSubscription? _timerStateSubscribtion;

  AppAuthorizedRouterBloc(this._getTimerRepository, this._getAppStateRepository)
    : super(AppAuthorizedRouterState.initializing());

  Future<void> init() async {
    await _timerStateSubscribtion?.cancel();
    _timerStateSubscribtion = _getTimerRepository()
        .observeIsSet()
        .distinct()
        .listen(_onStateChanged, onError: addError);
  }

  Future<void> _onStateChanged(bool isTimerSet) async {
    // Check if the selected date is today
    final selectedDate = await _getAppStateRepository().selectedDate;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isViewingToday =
        selectedDate == null ||
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day) ==
            today;

    emit(
      AppAuthorizedRouterState.idle(
        isTimerSet: isTimerSet,
        isViewingToday: isViewingToday,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _timerStateSubscribtion?.cancel();
    return super.close();
  }
}
