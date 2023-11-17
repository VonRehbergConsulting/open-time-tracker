import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'inject.config.dart';

final GetIt _getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() => _getIt.init();

T inject<T extends Object>({
  String? instanceName,
  dynamic param1,
  dynamic param2,
}) =>
    _getIt.get<T>(
      instanceName: instanceName,
      param1: param1,
      param2: param2,
    );
