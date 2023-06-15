import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvVars {
  static String? get(String name) {
    return dotenv.env[name];
  }
}
