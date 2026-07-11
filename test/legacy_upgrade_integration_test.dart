import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_project_time_tracker/app/auth/infrastructure/secure_auth_token_storage.dart';
import 'package:open_project_time_tracker/app/instances/infrastructure/local_instances_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/mock_secure_storage.dart';

/// End-to-end test for the "legacy single-instance install upgrading
/// to the multi-instance build" scenario.
///
/// This is the exact code path every existing user hits exactly once
/// on the version that introduces multi-instance support. If it
/// silently breaks, every user's first launch after the update logs
/// them out without any visible error.
///
/// The test wires together the two production components that
/// collaborate at upgrade time:
///   * [LocalInstancesRepository] — reads legacy `baseUrl`+`clientId`
///     from `SharedPreferences`, mints a new instance id, invokes the
///     migration hook.
///   * [SecureAuthTokenStorage] — hook target; reads legacy tokens
///     from `flutter_secure_storage`, rewrites them under the scoped
///     per-instance keyspace, deletes the legacy keys.
///
/// The wiring lambda mirrors the one in `app_module.dart`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSecureStorage secureStorage;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    secureStorage = MockSecureStorage()..install();
  });

  tearDown(() {
    secureStorage.uninstall();
  });

  test(
    'a legacy install migrates prefs + tokens end-to-end on first '
    'load(), and the migrated tokens are readable under the new id',
    () async {
      // Seed the pre-upgrade state of an existing user's device.
      SharedPreferences.setMockInitialValues({
        'baseUrl': 'https://openproject.example.com',
        'clientId': 'legacy-client-id',
      });
      secureStorage.seed({
        'accessToken': 'legacy-access-token',
        'refreshToken': 'legacy-refresh-token',
      });

      // The token storage's resolver reads the active instance id from
      // the instances repo (mirrors the DI wiring in app_module.dart).
      late final LocalInstancesRepository instancesRepo;
      final tokenStorage = SecureAuthTokenStorage.withKeys(
        const FlutterSecureStorage(),
        accessTokenKey: 'accessToken',
        refreshTokenKey: 'refreshToken',
        resolveActiveInstanceId: () => instancesRepo.current.activeInstanceId,
      );

      // Migration hook mirrors app_module.dart's lambda: on first
      // launch, port the legacy tokens to the per-instance keyspace.
      instancesRepo = LocalInstancesRepository(
        onLegacyTokenMigration: (newInstanceId) =>
            tokenStorage.migrateLegacyTokens(newInstanceId),
      );

      // Act: the first load() on the new build.
      final snapshot = await instancesRepo.load();

      // A single instance was minted from the legacy config.
      expect(snapshot.instances, hasLength(1));
      final instance = snapshot.instances.single;
      expect(snapshot.activeInstanceId, instance.id);
      expect(instance.baseUrl, 'https://openproject.example.com');
      expect(instance.clientId, 'legacy-client-id');

      // The legacy prefs keys are removed; the new-format keys are
      // present.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('baseUrl'), isNull);
      expect(prefs.getString('clientId'), isNull);
      expect(prefs.getString('openproject.instances'), isNotNull);
      expect(prefs.getString('openproject.activeInstanceId'), instance.id);

      // The legacy token keys are gone from secure storage; the tokens
      // now live under the scoped per-instance keys.
      expect(secureStorage.data.containsKey('accessToken'), isFalse);
      expect(secureStorage.data.containsKey('refreshToken'), isFalse);
      expect(
        secureStorage.data['accessToken.${instance.id}'],
        'legacy-access-token',
      );
      expect(
        secureStorage.data['refreshToken.${instance.id}'],
        'legacy-refresh-token',
      );

      // The token storage, with its resolver now returning the new id
      // (via the just-migrated instances repo), can retrieve the
      // migrated tokens — the user stays signed in.
      final token = await tokenStorage.getToken();
      expect(token, isNotNull);
      expect(token!.accessToken, 'legacy-access-token');
      expect(token.refreshToken, 'legacy-refresh-token');
    },
  );

  test('a second launch after the upgrade does not re-migrate and leaves '
      'the migrated tokens intact', () async {
    SharedPreferences.setMockInitialValues({
      'baseUrl': 'https://openproject.example.com',
      'clientId': 'legacy-client-id',
    });
    secureStorage.seed({
      'accessToken': 'legacy-access-token',
      'refreshToken': 'legacy-refresh-token',
    });

    // First launch (as above).
    late final LocalInstancesRepository firstRepo;
    final firstStorage = SecureAuthTokenStorage.withKeys(
      const FlutterSecureStorage(),
      accessTokenKey: 'accessToken',
      refreshTokenKey: 'refreshToken',
      resolveActiveInstanceId: () => firstRepo.current.activeInstanceId,
    );
    firstRepo = LocalInstancesRepository(
      onLegacyTokenMigration: (id) => firstStorage.migrateLegacyTokens(id),
    );
    final firstSnapshot = await firstRepo.load();
    final migratedId = firstSnapshot.instances.single.id;

    // Second launch: fresh repositories against the *already
    // migrated* prefs + secure storage. The migration hook must NOT
    // fire (there's no legacy prefs left to trigger it), and the
    // scoped tokens must still be present and readable.
    var hookCalls = 0;
    late final LocalInstancesRepository secondRepo;
    final secondStorage = SecureAuthTokenStorage.withKeys(
      const FlutterSecureStorage(),
      accessTokenKey: 'accessToken',
      refreshTokenKey: 'refreshToken',
      resolveActiveInstanceId: () => secondRepo.current.activeInstanceId,
    );
    secondRepo = LocalInstancesRepository(
      onLegacyTokenMigration: (_) async => hookCalls++,
    );

    final secondSnapshot = await secondRepo.load();

    expect(hookCalls, 0);
    expect(secondSnapshot.instances.single.id, migratedId);
    expect(secondSnapshot.activeInstanceId, migratedId);

    final token = await secondStorage.getToken();
    expect(token, isNotNull);
    expect(token!.accessToken, 'legacy-access-token');
    expect(token.refreshToken, 'legacy-refresh-token');
  });

  test('a fresh install (no legacy prefs, no legacy tokens) migrates '
      'nothing and yields an empty snapshot', () async {
    final tokenStorage = SecureAuthTokenStorage.withKeys(
      const FlutterSecureStorage(),
      accessTokenKey: 'accessToken',
      refreshTokenKey: 'refreshToken',
      resolveActiveInstanceId: () => null,
    );
    var hookCalls = 0;
    final instancesRepo = LocalInstancesRepository(
      onLegacyTokenMigration: (id) async {
        hookCalls++;
        await tokenStorage.migrateLegacyTokens(id);
      },
    );

    final snapshot = await instancesRepo.load();

    expect(snapshot.instances, isEmpty);
    expect(snapshot.activeInstanceId, isNull);
    expect(hookCalls, 0);
    expect(secureStorage.data, isEmpty);
  });
}
