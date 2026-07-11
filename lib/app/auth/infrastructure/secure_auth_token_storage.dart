import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_token_storage.dart';

/// Persists OAuth tokens in [FlutterSecureStorage] under keys optionally
/// scoped by the currently active OpenProject instance id, so credentials
/// for different instances never collide.
///
/// The active id is resolved lazily via [_resolveActiveInstanceId] on
/// every call so that the storage always reflects the latest switch
/// without needing an explicit rewire.
///
/// When the resolver returns `null` (or when no resolver is provided —
/// e.g. the Microsoft Graph token store which is not per-instance), the
/// raw base keys are used. This also gracefully preserves legacy
/// unscoped tokens the first time an instance is created and until the
/// migration hook re-keys them.
class SecureAuthTokenStorage implements AuthTokenStorage {
  final FlutterSecureStorage _storage;
  final String? Function()? _resolveActiveInstanceId;

  final String accessTokenKey;
  final String refreshTokenKey;

  AuthToken? _current;
  @override
  AuthToken? get current => _current?.copyWith();

  SecureAuthTokenStorage(this._storage, [this._resolveActiveInstanceId])
    : accessTokenKey = _accessTokenKeyDefault,
      refreshTokenKey = _refreshTokenKeyDefault;

  /// Named constructor kept for call sites that already pass explicit
  /// key names (Graph module, tests) — mirrors the previous API but
  /// makes the resolver optional.
  SecureAuthTokenStorage.withKeys(
    this._storage, {
    required this.accessTokenKey,
    required this.refreshTokenKey,
    String? Function()? resolveActiveInstanceId,
  }) : _resolveActiveInstanceId = resolveActiveInstanceId;

  static const _accessTokenKeyDefault = 'accessToken';
  static const _refreshTokenKeyDefault = 'refreshToken';

  String _scopedKey(String base) {
    final resolver = _resolveActiveInstanceId;
    final id = resolver == null ? null : resolver();
    if (id == null) return base;
    return '$base.$id';
  }

  @override
  Future<void> clear() async {
    final accessKey = _scopedKey(accessTokenKey);
    final refreshKey = _scopedKey(refreshTokenKey);
    await _storage.write(key: accessKey, value: null);
    await _storage.write(key: refreshKey, value: null);
    _current = null;
  }

  @override
  Future<void> clearAll() async {
    // Enumerate the secure-storage keyspace once and delete every key
    // that belongs to this storage's namespace:
    //   * the bare base key (legacy, pre-multi-instance), and
    //   * any '$base.<scope>' key.
    // The '.' delimiter check prevents accidentally matching a sibling
    // storage whose base key merely shares a prefix (e.g. the Graph
    // token store uses 'graphAccessToken' which would otherwise be
    // caught by a startsWith('accessToken') check).
    try {
      final all = await _storage.readAll();
      final accessPrefix = '$accessTokenKey.';
      final refreshPrefix = '$refreshTokenKey.';
      for (final key in all.keys) {
        final matches =
            key == accessTokenKey ||
            key == refreshTokenKey ||
            key.startsWith(accessPrefix) ||
            key.startsWith(refreshPrefix);
        if (matches) {
          await _storage.delete(key: key);
        }
      }
    } catch (e) {
      debugPrint('Secure storage clearAll failed: $e');
    }
    _current = null;
  }

  @override
  Future<AuthToken?> getToken() async {
    final accessKey = _scopedKey(accessTokenKey);
    final refreshKey = _scopedKey(refreshTokenKey);
    try {
      final accessToken = await _storage.read(key: accessKey);
      final refreshToken = await _storage.read(key: refreshKey);
      final token = accessToken == null || refreshToken == null
          ? null
          : AuthToken(accessToken: accessToken, refreshToken: refreshToken);
      _current = token;
      return token;
    } catch (e) {
      // Handle decryption errors (e.g., BadPaddingException after OS/app
      // updates). Clear corrupted data and return null to trigger
      // re-authentication.
      debugPrint('Secure storage read failed (likely corrupted): $e');
      try {
        await clear();
      } catch (clearError) {
        debugPrint('Failed to clear corrupted secure storage: $clearError');
      }
      return null;
    }
  }

  @override
  Future<void> setToken(AuthToken token) async {
    final accessKey = _scopedKey(accessTokenKey);
    final refreshKey = _scopedKey(refreshTokenKey);
    await _storage.write(key: accessKey, value: token.accessToken);
    await _storage.write(key: refreshKey, value: token.refreshToken);
    _current = token;
  }

  /// One-time port of tokens from the pre-multi-instance keys to the
  /// per-instance keyspace. Called by the instances-repo migration hook
  /// with the id assigned to the migrated legacy instance. Safe to call
  /// even when no legacy tokens are present.
  Future<void> migrateLegacyTokens(String instanceId) async {
    try {
      final legacyAccess = await _storage.read(key: accessTokenKey);
      final legacyRefresh = await _storage.read(key: refreshTokenKey);
      if (legacyAccess != null) {
        await _storage.write(
          key: '$accessTokenKey.$instanceId',
          value: legacyAccess,
        );
        await _storage.write(key: accessTokenKey, value: null);
      }
      if (legacyRefresh != null) {
        await _storage.write(
          key: '$refreshTokenKey.$instanceId',
          value: legacyRefresh,
        );
        await _storage.write(key: refreshTokenKey, value: null);
      }
    } catch (e) {
      debugPrint('Legacy token migration failed: $e');
    }
  }
}
