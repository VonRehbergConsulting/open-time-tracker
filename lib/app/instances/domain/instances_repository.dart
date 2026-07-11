import 'package:open_project_time_tracker/app/instances/domain/open_project_instance.dart';

/// Snapshot of the configured OpenProject instances at a point in time.
class InstancesSnapshot {
  const InstancesSnapshot({
    required this.instances,
    required this.activeInstanceId,
  });

  final List<OpenProjectInstance> instances;
  final String? activeInstanceId;

  OpenProjectInstance? get activeInstance {
    final id = activeInstanceId;
    if (id == null) return null;
    for (final instance in instances) {
      if (instance.id == id) return instance;
    }
    return null;
  }

  bool get hasAny => instances.isNotEmpty;
}

/// Repository owning the list of configured OpenProject [OpenProjectInstance]s
/// and the id of the currently active one.
///
/// Emits a new [InstancesSnapshot] whenever the list or the active id
/// changes so downstream services (auth, api) can react to a switch.
abstract class InstancesRepository {
  /// Latest cached snapshot. Non-null after [load] has completed at
  /// least once; guaranteed synchronous access for hot paths.
  InstancesSnapshot get current;

  /// Fires a new snapshot on every mutation (add / update / remove /
  /// activate). Replays the latest value on subscribe.
  Stream<InstancesSnapshot> observe();

  /// Loads instances from persistent storage if not already loaded.
  /// Performs a one-time migration from the legacy single-instance keys
  /// on first read. Idempotent.
  Future<InstancesSnapshot> load();

  Future<OpenProjectInstance> add({
    required String label,
    required String baseUrl,
    required String clientId,
  });

  Future<OpenProjectInstance> update(OpenProjectInstance instance);

  Future<void> remove(String id);

  /// Sets the given [id] as the active instance. Passing `null` clears
  /// the active instance (used when the last one is removed).
  Future<void> setActive(String? id);
}
