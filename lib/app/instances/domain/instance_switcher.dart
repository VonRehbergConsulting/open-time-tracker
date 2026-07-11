/// Outcome of an [InstanceSwitcher.switchTo] call.
enum InstanceSwitchResult {
  /// The requested instance is already active; nothing was done.
  alreadyActive,

  /// Switch completed successfully.
  switched,

  /// A timer is running for the current instance. The caller must
  /// resolve it (save or discard) and retry with [force] set to true.
  blockedByActiveTimer,
}

/// Coordinates changing the currently active OpenProject instance.
///
/// Responsibilities:
///  * Guard against silently orphaning an in-progress timer when the
///    user switches away.
///  * Perform the atomic swap (repository → auth service refresh → user
///    data cache clear) so downstream blocs land on a consistent state.
abstract class InstanceSwitcher {
  /// Switches the active instance to [instanceId].
  ///
  /// When [force] is `false` (the default) and a timer is currently
  /// active, the call returns [InstanceSwitchResult.blockedByActiveTimer]
  /// without touching anything. The UI is expected to show a
  /// save-or-discard prompt and retry with [force] set to `true` after
  /// the user resolves the timer.
  Future<InstanceSwitchResult> switchTo(
    String instanceId, {
    bool force = false,
  });
}
