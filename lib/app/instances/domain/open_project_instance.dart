import 'package:freezed_annotation/freezed_annotation.dart';

part 'open_project_instance.freezed.dart';
part 'open_project_instance.g.dart';

/// A configured OpenProject server the user can authenticate against.
///
/// [id] is a stable, opaque identifier generated when the instance is
/// created; it is used as the suffix for per-instance storage keys
/// (auth tokens, etc.) so that credentials from different instances
/// never collide.
@freezed
class OpenProjectInstance with _$OpenProjectInstance {
  const factory OpenProjectInstance({
    required String id,
    required String label,
    required String baseUrl,
    required String clientId,
  }) = _OpenProjectInstance;

  factory OpenProjectInstance.fromJson(Map<String, dynamic> json) =>
      _$OpenProjectInstanceFromJson(json);

  /// Strips a single trailing slash from [value] so URLs entered as
  /// `https://openproject.example.com/` and `https://openproject.example.com`
  /// are stored identically.
  static String normalizeBaseUrl(String value) {
    final trimmed = value.trim();
    return trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }
}
