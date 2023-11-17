import 'package:bloc/bloc.dart' as bloc;
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_project_time_tracker/app/di/inject.dart';

// ignore: depend_on_referenced_packages
export 'package:provider/provider.dart'
    show ProviderNotFoundException, ReadContext, SelectContext, WatchContext;

export 'effect_bloc.dart';

abstract class Bloc<Event, State> extends bloc.Bloc<Event, State> {
  Bloc(super.initialState);
}

abstract class Cubit<State> extends bloc.Cubit<State> {
  Cubit(super.initialState);
}

class InjectableBlocConsumer<B extends BlocBase<S>, S> extends StatelessWidget {
  final BlocWidgetBuilder<S> builder;
  final BlocWidgetListener<S>? listener;
  final BlocBuilderCondition<S>? buildWhen;
  final void Function(BuildContext context, B bloc)? onCreate;
  final B Function(BuildContext context)? create;

  final dynamic param1;
  final dynamic param2;

  const InjectableBlocConsumer({
    super.key,
    required this.builder,
    this.listener,
    this.buildWhen,
    this.onCreate,
    this.param1,
    this.param2,
    this.create,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<B>(
      create: create ??
          (context) {
            final bloc = inject<B>(param1: param1, param2: param2);
            onCreate?.call(context, bloc);
            return bloc;
          },
      child: listener != null
          ? BlocConsumer<B, S>(
              builder: builder,
              listener: listener!,
            )
          : BlocBuilder<B, S>(
              builder: builder,
            ),
    );
  }
}
