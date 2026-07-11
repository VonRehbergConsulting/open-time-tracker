import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:open_project_time_tracker/app/instances/domain/instances_repository.dart';
import 'package:open_project_time_tracker/app/instances/domain/open_project_instance.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalInstancesRepository implements InstancesRepository {
  LocalInstancesRepository({
    this.legacyBaseUrlKey = _defaultLegacyBaseUrlKey,
    this.legacyClientIdKey = _defaultLegacyClientIdKey,
    this.onLegacyTokenMigration,
  });

  static const _instancesKey = 'openproject.instances';
  static const _activeInstanceIdKey = 'openproject.activeInstanceId';

  static const _defaultLegacyBaseUrlKey = 'baseUrl';
  static const _defaultLegacyClientIdKey = 'clientId';

  final String legacyBaseUrlKey;
  final String legacyClientIdKey;

  /// Optional hook invoked with the newly-minted instance id when the
  /// legacy single-instance configuration gets migrated. Consumers
  /// (namely the secure token storage) use this signal to re-key any
  /// existing OAuth tokens from the unscoped legacy keyspace to the
  /// per-instance one, so the user does not have to log in again.
  ///
  /// The tokens themselves live in `flutter_secure_storage`, not
  /// `SharedPreferences`, so the consumer reads and rewrites them
  /// itself — this hook only communicates the target instance id and
  /// the fact that migration is happening.
  final Future<void> Function(String newInstanceId)? onLegacyTokenMigration;

  final _subject = BehaviorSubject<InstancesSnapshot>();
  Future<InstancesSnapshot>? _loading;
  InstancesSnapshot _current = const InstancesSnapshot(
    instances: [],
    activeInstanceId: null,
  );

  @override
  InstancesSnapshot get current => _current;

  @override
  Stream<InstancesSnapshot> observe() => _subject.stream;

  @override
  Future<InstancesSnapshot> load() {
    return _loading ??= _loadInternal();
  }

  Future<InstancesSnapshot> _loadInternal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_instancesKey);

    List<OpenProjectInstance> instances;
    String? activeId;

    if (raw != null) {
      instances = _decode(raw);
      activeId = prefs.getString(_activeInstanceIdKey);
      // Guard against a stale active id pointing at a deleted instance.
      if (activeId != null &&
          !instances.any((instance) => instance.id == activeId)) {
        activeId = instances.isNotEmpty ? instances.first.id : null;
        await _writeActive(prefs, activeId);
      }
    } else {
      // No new-format data yet — attempt one-time migration from the
      // legacy single-instance keys.
      final migrated = await _migrateLegacy(prefs);
      instances = migrated.instances;
      activeId = migrated.activeInstanceId;
      if (instances.isNotEmpty) {
        await _writeInstances(prefs, instances);
        await _writeActive(prefs, activeId);
      }
    }

    final snapshot = InstancesSnapshot(
      instances: List.unmodifiable(instances),
      activeInstanceId: activeId,
    );
    _current = snapshot;
    _subject.add(snapshot);
    return snapshot;
  }

  Future<InstancesSnapshot> _migrateLegacy(SharedPreferences prefs) async {
    final legacyBaseUrl = prefs.getString(legacyBaseUrlKey);
    final legacyClientId = prefs.getString(legacyClientIdKey);
    if (legacyBaseUrl == null ||
        legacyBaseUrl.isEmpty ||
        legacyClientId == null ||
        legacyClientId.isEmpty) {
      return const InstancesSnapshot(instances: [], activeInstanceId: null);
    }

    final id = _generateId();
    final instance = OpenProjectInstance(
      id: id,
      // Best-effort human-readable label from the URL host (e.g.
      // `openproject.example.com`). Users can rename later via the
      // editor.
      label: _deriveLabelFromBaseUrl(legacyBaseUrl),
      baseUrl: OpenProjectInstance.normalizeBaseUrl(legacyBaseUrl),
      clientId: legacyClientId.trim(),
    );

    debugPrint(
      'Migrating legacy OpenProject configuration to instance $id '
      '(${instance.label}).',
    );

    // Best-effort port of legacy tokens so the user stays signed in.
    // The hook resolves the secure token storage lazily and re-keys
    // any existing tokens under the new instance id.
    try {
      await onLegacyTokenMigration?.call(id);
    } catch (e) {
      debugPrint('Legacy token migration hook failed: $e');
    }

    // Drop legacy prefs keys so we never migrate twice.
    await prefs.remove(legacyBaseUrlKey);
    await prefs.remove(legacyClientIdKey);

    return InstancesSnapshot(instances: [instance], activeInstanceId: id);
  }

  @override
  Future<OpenProjectInstance> add({
    required String label,
    required String baseUrl,
    required String clientId,
  }) async {
    await load();
    final prefs = await SharedPreferences.getInstance();
    final instance = OpenProjectInstance(
      id: _generateId(),
      label: label,
      baseUrl: baseUrl,
      clientId: clientId,
    );
    final next = [..._current.instances, instance];
    await _writeInstances(prefs, next);
    // If nothing was active before, adopt the newcomer.
    final activeId = _current.activeInstanceId ?? instance.id;
    if (_current.activeInstanceId == null) {
      await _writeActive(prefs, activeId);
    }
    _emit(
      InstancesSnapshot(
        instances: List.unmodifiable(next),
        activeInstanceId: activeId,
      ),
    );
    return instance;
  }

  @override
  Future<OpenProjectInstance> update(OpenProjectInstance instance) async {
    await load();
    final prefs = await SharedPreferences.getInstance();
    final index = _current.instances.indexWhere((i) => i.id == instance.id);
    if (index < 0) {
      throw StateError('Instance ${instance.id} not found');
    }
    final next = [..._current.instances];
    next[index] = instance;
    await _writeInstances(prefs, next);
    _emit(
      InstancesSnapshot(
        instances: List.unmodifiable(next),
        activeInstanceId: _current.activeInstanceId,
      ),
    );
    return instance;
  }

  @override
  Future<void> remove(String id) async {
    await load();
    final prefs = await SharedPreferences.getInstance();
    final next = _current.instances.where((i) => i.id != id).toList();
    await _writeInstances(prefs, next);
    String? activeId = _current.activeInstanceId;
    if (activeId == id) {
      // Fall back to the first remaining instance, or clear if none.
      activeId = next.isNotEmpty ? next.first.id : null;
      await _writeActive(prefs, activeId);
    }
    _emit(
      InstancesSnapshot(
        instances: List.unmodifiable(next),
        activeInstanceId: activeId,
      ),
    );
  }

  @override
  Future<void> setActive(String? id) async {
    await load();
    if (id != null && !_current.instances.any((i) => i.id == id)) {
      throw StateError('Cannot activate unknown instance $id');
    }
    if (_current.activeInstanceId == id) return;
    final prefs = await SharedPreferences.getInstance();
    await _writeActive(prefs, id);
    _emit(
      InstancesSnapshot(
        instances: _current.instances,
        activeInstanceId: id,
      ),
    );
  }

  Future<void> _writeInstances(
    SharedPreferences prefs,
    List<OpenProjectInstance> instances,
  ) {
    final encoded = jsonEncode(instances.map((i) => i.toJson()).toList());
    return prefs.setString(_instancesKey, encoded);
  }

  Future<void> _writeActive(SharedPreferences prefs, String? id) {
    if (id == null) return prefs.remove(_activeInstanceIdKey);
    return prefs.setString(_activeInstanceIdKey, id);
  }

  void _emit(InstancesSnapshot snapshot) {
    _current = snapshot;
    _subject.add(snapshot);
  }

  List<OpenProjectInstance> _decode(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(OpenProjectInstance.fromJson)
          .toList();
    } catch (e) {
      debugPrint('Failed to decode instances list: $e');
      return const [];
    }
  }

  String _generateId() {
    final ms = DateTime.now().microsecondsSinceEpoch;
    final rand = Random().nextInt(1 << 32);
    return '${ms.toRadixString(16)}-${rand.toRadixString(16)}';
  }

  String _deriveLabelFromBaseUrl(String baseUrl) {
    try {
      var host = Uri.parse(baseUrl).host;
      if (host.isNotEmpty) {
        // Drop a leading `www.` for a cleaner label.
        if (host.toLowerCase().startsWith('www.')) {
          host = host.substring(4);
        }
        return host;
      }
    } catch (_) {
      // fall through
    }
    return 'OpenProject';
  }
}
