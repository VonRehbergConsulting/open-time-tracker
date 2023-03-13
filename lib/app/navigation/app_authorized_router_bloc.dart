import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/modules/timer/domain/timer_repository.dart';

import '../ui/bloc/bloc.dart';

part 'app_authorized_router_bloc.freezed.dart';

@freezed
class AppAuthorizedRouterState with _$AppAuthorizedRouterState {
  factory AppAuthorizedRouterState.initializing() = _Initializing;
  factory AppAuthorizedRouterState.idle({required bool isTimerSet}) = _Idle;
}

class AppAuthorizedRouterBloc extends Cubit<AppAuthorizedRouterState> {
  final TimerRepository Function() _getTimerRepository;
  StreamSubscription? _timerStateSubscribtion;

  AppAuthorizedRouterBloc(this._getTimerRepository)
      : super(AppAuthorizedRouterState.initializing());

  Future<void> init() async {
    await _timerStateSubscribtion?.cancel();
    _timerStateSubscribtion = _getTimerRepository()
        .observeIsSet()
        .distinct()
        .listen(_onStateChanged, onError: addError);
  }

  Future<void> _onStateChanged(bool isTimerSet) async {
    emit(AppAuthorizedRouterState.idle(isTimerSet: isTimerSet));
  }

  @override
  Future<void> close() async {
    await _timerStateSubscribtion?.cancel();
    return super.close();
  }
}
