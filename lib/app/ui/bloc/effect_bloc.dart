import 'dart:async';

import 'package:bloc/bloc.dart' as bloc;
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_project_time_tracker/app/di/inject.dart';

abstract class EffectBlocBase<State, Effect> implements BlocBase<State> {
  Stream<Effect> get effectStream;

  void emitEffect(Effect effect);

  @mustCallSuper
  void onEffect(Effect effect);
}

abstract class EffectBloc<Event, State, Effect> extends bloc.Bloc<Event, State>
    implements EffectBlocBase<State, Effect> {
  EffectBloc(super.initialState);

  StreamController<Effect>? __effectController;

  StreamController<Effect> get _effectController {
    return __effectController ??= StreamController<Effect>.broadcast();
  }

  /// The current side effects stream.
  @override
  Stream<Effect> get effectStream => _effectController.stream;

  @override
  void emitEffect(Effect effect) {
    if (_effectController.isClosed) return;
    onEffect(effect);
    _effectController.add(effect);
  }

  @override
  @mustCallSuper
  void onEffect(Effect effect) {}

  Future<void> _closeEffect() async {
    await _effectController.close();
  }

  @override
  Future<void> close() {
    _closeEffect();
    return super.close();
  }
}

abstract class EffectCubit<State, Effect> extends bloc.Cubit<State>
    implements EffectBlocBase<State, Effect> {
  EffectCubit(super.initialState);

  StreamController<Effect>? __effectController;

  StreamController<Effect> get _effectController {
    return __effectController ??= StreamController<Effect>.broadcast();
  }

  /// The current side effects stream.
  @override
  Stream<Effect> get effectStream => _effectController.stream;

  @override
  void emitEffect(Effect effect) {
    if (_effectController.isClosed) return;
    onEffect(effect);
    _effectController.add(effect);
  }

  @override
  @mustCallSuper
  void onEffect(Effect effect) {}

  Future<void> _closeEffect() async {
    await _effectController.close();
  }

  @override
  Future<void> close() {
    _closeEffect();
    return super.close();
  }
}

typedef EffectBlocWidgetListener<E> = void Function(
  BuildContext context,
  E effect,
);

class EffectBlocConsumer<B extends EffectBlocBase<S, E>, S, E>
    extends StatefulWidget {
  final BlocWidgetBuilder<S> builder;
  final BlocWidgetListener<S>? listener;
  final EffectBlocWidgetListener<E> effectListener;
  final BlocBuilderCondition<S>? buildWhen;
  final B? bloc;

  const EffectBlocConsumer({
    required this.builder,
    required this.effectListener,
    this.listener,
    this.bloc,
    this.buildWhen,
    super.key,
  });

  @override
  State<EffectBlocConsumer<B, S, E>> createState() =>
      _EffectBlocConsumerState<B, S, E>();
}

class _EffectBlocConsumerState<B extends EffectBlocBase<S, E>, S, E>
    extends State<EffectBlocConsumer<B, S, E>> {
  late B _bloc;

  StreamSubscription<E>? _subscription;

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? context.read<B>();
    _subscribe();
  }

  @override
  void didUpdateWidget(EffectBlocConsumer<B, S, E> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldBloc = oldWidget.bloc ?? context.read<B>();
    final currentBloc = widget.bloc ?? oldBloc;
    if (oldBloc != currentBloc) {
      _bloc = currentBloc;
    }
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.listener != null
        ? BlocConsumer<B, S>(
            builder: widget.builder,
            listener: widget.listener!,
            buildWhen: widget.buildWhen,
            bloc: widget.bloc,
          )
        : BlocBuilder<B, S>(
            builder: widget.builder,
            buildWhen: widget.buildWhen,
            bloc: widget.bloc,
          );
  }

  void _subscribe() {
    _subscription = _bloc.effectStream.listen((state) {
      widget.effectListener(context, state);
    });
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }
}

class InjectableEffectBlocConsumer<B extends EffectBlocBase<S, E>, S, E>
    extends StatelessWidget {
  final BlocWidgetBuilder<S> builder;
  final BlocWidgetListener<S>? listener;
  final EffectBlocWidgetListener<E> effectListener;
  final BlocBuilderCondition<S>? buildWhen;
  final void Function(BuildContext context, B bloc)? onCreate;
  final B Function(BuildContext context)? create;

  final dynamic param1;
  final dynamic param2;

  const InjectableEffectBlocConsumer({
    required this.builder,
    required this.effectListener,
    this.listener,
    this.buildWhen,
    this.onCreate,
    this.param1,
    this.param2,
    this.create,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: create ??
          (context) {
            final bloc = inject<B>(param1: param1, param2: param2);
            onCreate?.call(context, bloc);
            return bloc;
          },
      child: EffectBlocConsumer<B, S, E>(
        builder: builder,
        listener: listener,
        effectListener: effectListener,
      ),
    );
  }
}
