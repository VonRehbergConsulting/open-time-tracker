import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory mock for the `flutter_secure_storage` MethodChannel plugin.
///
/// Intercepts calls on `plugins.it_nomads.com/flutter_secure_storage`
/// and backs them with a plain `Map<String, String>`. Supports every
/// method used by [SecureAuthTokenStorage]: `write`, `read`, `readAll`,
/// `delete`, plus `deleteAll` and `containsKey` for completeness.
///
/// Usage:
/// ```dart
/// final storage = MockSecureStorage()..install();
/// addTearDown(storage.uninstall);
/// storage.seed({'accessToken': 'legacy-access'});
/// ```
class MockSecureStorage {
  static const _channel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

  final Map<String, String> _data = {};

  /// Read-only view of what's currently stored.
  Map<String, String> get data => Map.unmodifiable(_data);

  /// Seed the store with initial values (e.g. legacy tokens).
  void seed(Map<String, String> initial) {
    _data
      ..clear()
      ..addAll(initial);
  }

  /// Register the mock handler on the platform channel.
  void install() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, _handle);
  }

  /// Remove the mock handler. Safe to call in `addTearDown`.
  void uninstall() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  }

  Future<Object?> _handle(MethodCall call) async {
    final args = (call.arguments as Map?)?.cast<String, Object?>() ?? const {};
    switch (call.method) {
      case 'write':
        _data[args['key']! as String] = args['value']! as String;
        return null;
      case 'read':
        return _data[args['key']! as String];
      case 'readAll':
        return Map<String, String>.from(_data);
      case 'delete':
        _data.remove(args['key']! as String);
        return null;
      case 'deleteAll':
        _data.clear();
        return null;
      case 'containsKey':
        return _data.containsKey(args['key']! as String);
      default:
        return null;
    }
  }
}
