import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_service.dart';
import 'package:open_project_time_tracker/app/instances/domain/instances_repository.dart';
import 'package:open_project_time_tracker/app/instances/domain/open_project_instance.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc.dart';

part 'instance_editor_bloc.freezed.dart';

@freezed
class InstanceEditorState with _$InstanceEditorState {
  const factory InstanceEditorState.idle({
    required bool isEditing,
    required String label,
    required String baseUrl,
    required String clientId,
  }) = _Idle;
}

@freezed
class InstanceEditorEffect with _$InstanceEditorEffect {
  const factory InstanceEditorEffect.hydrate({
    required String label,
    required String baseUrl,
    required String clientId,
  }) = _Hydrate;
  const factory InstanceEditorEffect.invalidLabel() = _InvalidLabel;
  const factory InstanceEditorEffect.invalidUrl() = _InvalidUrl;
  const factory InstanceEditorEffect.invalidClientId() = _InvalidClientId;
  const factory InstanceEditorEffect.saved({required String instanceId}) =
      _Saved;

  /// Emitted after a **new** instance was successfully created. The UI
  /// is expected to switch to it (respecting the timer guard) and
  /// launch the OAuth flow so the user does not have to hunt for a
  /// "log in" button after configuring the instance. Edits emit
  /// [_Saved] instead — no re-auth is needed unless credentials
  /// changed (which is handled inline by [InstanceEditorBloc.save]).
  const factory InstanceEditorEffect.createdAndNeedsAuth({
    required String instanceId,
  }) = _CreatedAndNeedsAuth;
}

class InstanceEditorBloc
    extends EffectCubit<InstanceEditorState, InstanceEditorEffect> {
  final InstancesRepository _instancesRepository;
  final AuthService _authService;

  OpenProjectInstance? _existing;

  InstanceEditorBloc(
    this._instancesRepository,
    this._authService,
  ) : super(
        const InstanceEditorState.idle(
          isEditing: false,
          label: '',
          baseUrl: '',
          clientId: '',
        ),
      );

  /// Called by the page's [onCreate] with the instance to edit, or
  /// `null` when the editor is used for adding a new one.
  void init({OpenProjectInstance? existing}) {
    _existing = existing;
    emit(
      InstanceEditorState.idle(
        isEditing: existing != null,
        label: existing?.label ?? '',
        baseUrl: existing?.baseUrl ?? '',
        clientId: existing?.clientId ?? '',
      ),
    );
    if (existing != null) {
      emitEffect(
        InstanceEditorEffect.hydrate(
          label: existing.label,
          baseUrl: existing.baseUrl,
          clientId: existing.clientId,
        ),
      );
    }
  }

  Future<void> save({
    required String label,
    required String baseUrl,
    required String clientId,
  }) async {
    final trimmedLabel = label.trim();
    final trimmedBaseUrl = OpenProjectInstance.normalizeBaseUrl(baseUrl);
    final trimmedClientId = clientId.trim();

    if (trimmedLabel.isEmpty) {
      emitEffect(const InstanceEditorEffect.invalidLabel());
      return;
    }
    if (!_isValidUrl(trimmedBaseUrl)) {
      emitEffect(const InstanceEditorEffect.invalidUrl());
      return;
    }
    if (trimmedClientId.isEmpty) {
      emitEffect(const InstanceEditorEffect.invalidClientId());
      return;
    }

    final existing = _existing;
    if (existing == null) {
      final created = await _instancesRepository.add(
        label: trimmedLabel,
        baseUrl: trimmedBaseUrl,
        clientId: trimmedClientId,
      );
      // Signal the page to switch to the new instance (respecting an
      // active timer on the previous instance) and kick off the OAuth
      // flow. The page pops itself once the flow settles.
      emitEffect(
        InstanceEditorEffect.createdAndNeedsAuth(instanceId: created.id),
      );
      return;
    }

    final credentialsChanged =
        existing.baseUrl != trimmedBaseUrl ||
        existing.clientId != trimmedClientId;

    await _instancesRepository.update(
      existing.copyWith(
        label: trimmedLabel,
        baseUrl: trimmedBaseUrl,
        clientId: trimmedClientId,
      ),
    );

    // A URL or client-id change invalidates the OAuth session for this
    // instance — the tokens were minted against the old configuration.
    if (credentialsChanged) {
      final isActive =
          _instancesRepository.current.activeInstanceId == existing.id;
      if (isActive) {
        // logout() clears tokens for the currently active instance and
        // notifies observers, which drops the user on the auth page.
        await _authService.logout();
      }
      // For non-active instances, stale tokens will simply fail on
      // next use and the auth interceptor will trigger re-auth; no
      // action needed here.
    }

    emitEffect(InstanceEditorEffect.saved(instanceId: existing.id));
  }

  static bool _isValidUrl(String value) {
    try {
      final uri = Uri.parse(value);
      return uri.host.isNotEmpty &&
          (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (_) {
      return false;
    }
  }
}
