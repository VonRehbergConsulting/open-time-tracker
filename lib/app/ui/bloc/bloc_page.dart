import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';

import 'bloc.dart';

export 'package:flutter_bloc/flutter_bloc.dart';

///
/// BlocPage
///
abstract class BlocPage<B extends BlocBase<S>, S> extends StatelessWidget {
  const BlocPage({super.key});

  @override
  Widget build(BuildContext context) {
    return InjectableBlocConsumer<B, S>(
      builder: buildState,
      listener: onStateChange,
      onCreate: onCreate,
    );
  }

  Widget buildState(BuildContext context, S state);

  void onStateChange(BuildContext context, S state) {}

  void onCreate(BuildContext context, B bloc) {}
}

///
/// EffectBlocPage
///
abstract class EffectBlocPage<B extends EffectBlocBase<S, E>, S, E>
    extends StatelessWidget {
  const EffectBlocPage({super.key});

  @override
  Widget build(BuildContext context) {
    return InjectableEffectBlocConsumer<B, S, E>(
      builder: buildState,
      effectListener: onEffect,
      listener: onStateChange,
      onCreate: onCreate,
    );
  }

  Widget buildState(BuildContext context, S state);

  void onEffect(BuildContext context, E effect);

  void onStateChange(BuildContext context, S state) {}

  void onCreate(BuildContext context, B bloc) {}
}
