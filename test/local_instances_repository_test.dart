import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:open_project_time_tracker/app/instances/domain/instances_repository.dart';
import 'package:open_project_time_tracker/app/instances/infrastructure/local_instances_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalInstancesRepository legacy migration', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('creates an instance from the legacy baseUrl + clientId and derives '
        'the label from the URL host', () async {
      SharedPreferences.setMockInitialValues({
        'baseUrl': 'https://openproject.example.com/',
        'clientId': 'legacy-client-id',
      });

      String? migratedId;
      final repo = LocalInstancesRepository(
        onLegacyTokenMigration: (id) async => migratedId = id,
      );

      final snapshot = await repo.load();

      expect(snapshot.instances, hasLength(1));
      final instance = snapshot.instances.single;
      expect(instance.label, 'openproject.example.com');
      // Trailing slash on the legacy URL is stripped for consistency
      // with values entered through the editor.
      expect(instance.baseUrl, 'https://openproject.example.com');
      expect(instance.clientId, 'legacy-client-id');
      expect(snapshot.activeInstanceId, instance.id);
      expect(migratedId, instance.id);

      // Legacy prefs keys are removed so we never migrate twice.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('baseUrl'), isNull);
      expect(prefs.getString('clientId'), isNull);
      // New-format data is persisted.
      expect(prefs.getString('openproject.instances'), isNotNull);
      expect(prefs.getString('openproject.activeInstanceId'), instance.id);
    });

    test('strips a leading www. from the label', () async {
      SharedPreferences.setMockInitialValues({
        'baseUrl': 'https://www.openproject.example.com',
        'clientId': 'client-id',
      });

      final repo = LocalInstancesRepository();
      final snapshot = await repo.load();

      expect(snapshot.instances.single.label, 'openproject.example.com');
    });

    test('yields an empty snapshot when no legacy data is present', () async {
      final repo = LocalInstancesRepository();
      final snapshot = await repo.load();

      expect(snapshot.instances, isEmpty);
      expect(snapshot.activeInstanceId, isNull);
      expect(snapshot.hasAny, isFalse);
    });

    test('is idempotent: a second load() after migration keeps the migrated '
        'instance and does not re-run the migration hook', () async {
      SharedPreferences.setMockInitialValues({
        'baseUrl': 'https://openproject.example.com',
        'clientId': 'client',
      });

      var hookCalls = 0;
      final repo = LocalInstancesRepository(
        onLegacyTokenMigration: (_) async => hookCalls++,
      );

      final first = await repo.load();
      final second = await repo.load();

      expect(hookCalls, 1);
      expect(second.instances, hasLength(1));
      expect(second.instances.single.id, first.instances.single.id);
    });

    test('prefers the new-format data when both are present', () async {
      final existingId = 'preexisting-id';
      SharedPreferences.setMockInitialValues({
        'baseUrl': 'https://legacy.example.com',
        'clientId': 'legacy-client',
        'openproject.instances': jsonEncode([
          {
            'id': existingId,
            'label': 'Existing',
            'baseUrl': 'https://new.example.com',
            'clientId': 'new-client',
          },
        ]),
        'openproject.activeInstanceId': existingId,
      });

      var hookCalls = 0;
      final repo = LocalInstancesRepository(
        onLegacyTokenMigration: (_) async => hookCalls++,
      );

      final snapshot = await repo.load();

      expect(hookCalls, 0);
      expect(snapshot.instances, hasLength(1));
      expect(snapshot.instances.single.id, existingId);
      expect(snapshot.activeInstanceId, existingId);
    });

    test('does not migrate when legacy values are empty strings', () async {
      SharedPreferences.setMockInitialValues({'baseUrl': '', 'clientId': ''});

      final repo = LocalInstancesRepository();
      final snapshot = await repo.load();

      expect(snapshot.instances, isEmpty);
    });
  });

  group('LocalInstancesRepository CRUD', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('add() adopts the first instance as the active one', () async {
      final repo = LocalInstancesRepository();
      await repo.load();

      final created = await repo.add(
        label: 'Work',
        baseUrl: 'https://work.example.com',
        clientId: 'client',
      );

      expect(repo.current.activeInstanceId, created.id);
      expect(repo.current.instances, hasLength(1));
    });

    test(
      'add() does not change the active instance when one already exists',
      () async {
        final repo = LocalInstancesRepository();
        await repo.load();

        final first = await repo.add(
          label: 'A',
          baseUrl: 'https://a.example.com',
          clientId: 'c',
        );
        final second = await repo.add(
          label: 'B',
          baseUrl: 'https://b.example.com',
          clientId: 'c',
        );

        expect(repo.current.activeInstanceId, first.id);
        expect(repo.current.instances.map((i) => i.id), [first.id, second.id]);
      },
    );

    test('remove() picks a fallback active instance when the active one is '
        'deleted', () async {
      final repo = LocalInstancesRepository();
      await repo.load();

      final a = await repo.add(
        label: 'A',
        baseUrl: 'https://a.example.com',
        clientId: 'c',
      );
      final b = await repo.add(
        label: 'B',
        baseUrl: 'https://b.example.com',
        clientId: 'c',
      );

      await repo.remove(a.id);

      expect(repo.current.instances.map((i) => i.id), [b.id]);
      expect(repo.current.activeInstanceId, b.id);
    });

    test(
      'remove() clears the active id when the last instance is deleted',
      () async {
        final repo = LocalInstancesRepository();
        await repo.load();

        final only = await repo.add(
          label: 'Only',
          baseUrl: 'https://only.example.com',
          clientId: 'c',
        );

        await repo.remove(only.id);

        expect(repo.current.instances, isEmpty);
        expect(repo.current.activeInstanceId, isNull);
        expect(repo.current.hasAny, isFalse);
      },
    );

    test('observe() emits on every mutation', () async {
      final repo = LocalInstancesRepository();
      await repo.load();

      final snapshots = <InstancesSnapshot>[];
      final sub = repo.observe().listen(snapshots.add);

      final created = await repo.add(
        label: 'A',
        baseUrl: 'https://a.example.com',
        clientId: 'c',
      );
      await repo.update(created.copyWith(label: 'A2'));
      await repo.remove(created.id);
      // Let the BehaviorSubject dispatch queued microtasks before we
      // tear down the subscription and inspect the tail.
      await Future<void>.delayed(Duration.zero);

      await sub.cancel();

      expect(snapshots, hasLength(greaterThanOrEqualTo(3)));
      expect(snapshots.last.instances, isEmpty);
    });
  });
}
