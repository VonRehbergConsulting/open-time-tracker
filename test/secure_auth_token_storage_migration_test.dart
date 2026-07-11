import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_project_time_tracker/app/auth/infrastructure/secure_auth_token_storage.dart';

import 'support/mock_secure_storage.dart';

/// These tests lock in the contract that
/// [SecureAuthTokenStorage.migrateLegacyTokens] must satisfy so a
/// legacy single-instance install upgrading to the multi-instance
/// build does not silently log the user out.
///
/// The scenario is a one-shot, one-way migration:
///   * legacy build stored tokens in `flutter_secure_storage` under
///     the bare keys `'accessToken'` / `'refreshToken'`;
///   * the multi-instance build stores them under scoped keys
///     `'accessToken.<instanceId>'` / `'refreshToken.<instanceId>'`;
///   * on first launch of the new build, `LocalInstancesRepository`
///     mints an instance id and invokes the migration hook, which
///     resolves this storage and calls `migrateLegacyTokens(id)`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const activeId = 'inst-abc123';
  const accessKey = 'accessToken';
  const refreshKey = 'refreshToken';
  const scopedAccessKey = 'accessToken.inst-abc123';
  const scopedRefreshKey = 'refreshToken.inst-abc123';

  late MockSecureStorage mock;
  late SecureAuthTokenStorage storage;
  String? Function()? currentResolver;

  setUp(() {
    mock = MockSecureStorage()..install();
    currentResolver = () => activeId;
    storage = SecureAuthTokenStorage.withKeys(
      const FlutterSecureStorage(),
      accessTokenKey: accessKey,
      refreshTokenKey: refreshKey,
      resolveActiveInstanceId: () => currentResolver?.call(),
    );
  });

  tearDown(() {
    mock.uninstall();
  });

  group('SecureAuthTokenStorage.migrateLegacyTokens', () {
    test(
      're-keys both tokens under the per-instance keyspace and deletes '
      'the legacy keys',
      () async {
        mock.seed({
          accessKey: 'legacy-access-token',
          refreshKey: 'legacy-refresh-token',
        });

        await storage.migrateLegacyTokens(activeId);

        expect(mock.data.containsKey(accessKey), isFalse);
        expect(mock.data.containsKey(refreshKey), isFalse);
        expect(mock.data[scopedAccessKey], 'legacy-access-token');
        expect(mock.data[scopedRefreshKey], 'legacy-refresh-token');
      },
    );

    test(
      'is a no-op when no legacy tokens are present (fresh install or '
      'already-migrated user relaunching)',
      () async {
        expect(mock.data, isEmpty);

        await storage.migrateLegacyTokens(activeId);

        expect(mock.data, isEmpty);
      },
    );

    test(
      'migrates the access token alone when the refresh token is missing '
      '(partial legacy state, e.g. after a failed refresh)',
      () async {
        mock.seed({accessKey: 'legacy-access-only'});

        await storage.migrateLegacyTokens(activeId);

        expect(mock.data[scopedAccessKey], 'legacy-access-only');
        expect(mock.data.containsKey(scopedRefreshKey), isFalse);
        expect(mock.data.containsKey(accessKey), isFalse);
        expect(mock.data.containsKey(refreshKey), isFalse);
      },
    );

    test(
      'migrates the refresh token alone when the access token is missing',
      () async {
        mock.seed({refreshKey: 'legacy-refresh-only'});

        await storage.migrateLegacyTokens(activeId);

        expect(mock.data[scopedRefreshKey], 'legacy-refresh-only');
        expect(mock.data.containsKey(scopedAccessKey), isFalse);
        expect(mock.data.containsKey(refreshKey), isFalse);
      },
    );

    test(
      'after migration, getToken() with the resolver returning the new '
      'id returns the migrated token pair',
      () async {
        mock.seed({
          accessKey: 'legacy-access',
          refreshKey: 'legacy-refresh',
        });

        await storage.migrateLegacyTokens(activeId);
        final token = await storage.getToken();

        expect(token, isNotNull);
        expect(token!.accessToken, 'legacy-access');
        expect(token.refreshToken, 'legacy-refresh');
      },
    );

    test('is idempotent: a second call with the same id is a safe no-op',
        () async {
      mock.seed({
        accessKey: 'legacy-access',
        refreshKey: 'legacy-refresh',
      });

      await storage.migrateLegacyTokens(activeId);
      final afterFirst = Map<String, String>.from(mock.data);

      await storage.migrateLegacyTokens(activeId);

      expect(mock.data, equals(afterFirst));
    });

    test(
      'swallows platform exceptions (best-effort contract): user is '
      'logged out but the app does not crash',
      () async {
        // Replace the mock with one that throws for read, simulating a
        // corrupt or locked secure store.
        mock.uninstall();
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel(
            'plugins.it_nomads.com/flutter_secure_storage',
          ),
          (call) async {
            if (call.method == 'read') {
              throw PlatformException(code: 'BadPaddingException');
            }
            return null;
          },
        );
        addTearDown(() {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
            const MethodChannel(
              'plugins.it_nomads.com/flutter_secure_storage',
            ),
            null,
          );
        });

        // Must not throw.
        await storage.migrateLegacyTokens(activeId);
      },
    );
  });
}
