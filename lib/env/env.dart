import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'CLIENT_ID', obfuscate: true)
  static final clientId = _Env.clientId;
  @EnviedField(varName: 'BASE_URL')
  static const baseUrl = _Env.baseUrl;
}
