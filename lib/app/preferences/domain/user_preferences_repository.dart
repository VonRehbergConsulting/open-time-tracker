/// Cross-cutting, user-scoped persisted preferences that are not
/// specific to any feature module.
///
/// - [workingHours]: user's expected daily work duration; used by the
///   time-entries list to compute over/undertime.
/// - [analyticsConsent]: opt-in flag for the analytics service.
///
/// Purely presentational preferences (theme) live in
/// [UiSettingsRepository] under `lib/app/settings/`, which uses a
/// reactive stream. Nothing here needs to be observed, so this
/// repository stays async-per-read.
abstract class UserPreferencesRepository {
  Future<Duration> get workingHours;
  Future<void> setWorkingHours(Duration value);

  /// `null` = user hasn't answered the consent prompt yet.
  Future<bool?> get analyticsConsent;
  Future<void> setAnalyticsConsent(bool value);
}
