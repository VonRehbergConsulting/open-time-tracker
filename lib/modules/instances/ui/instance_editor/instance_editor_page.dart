import 'dart:async';

import 'package:flutter/material.dart' hide FilledButton;
import 'package:open_project_time_tracker/app/app_router.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_service.dart';
import 'package:open_project_time_tracker/app/di/inject.dart';
import 'package:open_project_time_tracker/app/instances/domain/instance_switcher.dart';
import 'package:open_project_time_tracker/app/instances/domain/open_project_instance.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc_page.dart';
import 'package:open_project_time_tracker/app/ui/widgets/filled_button.dart';
import 'package:open_project_time_tracker/l10n/app_localizations.dart';
import 'package:open_project_time_tracker/modules/instances/ui/instance_editor/instance_editor_bloc.dart';
import 'package:open_project_time_tracker/modules/instances/ui/switcher/timer_switch_prompt.dart';

class InstanceEditorPage
    extends
        EffectBlocPage<
          InstanceEditorBloc,
          InstanceEditorState,
          InstanceEditorEffect
        > {
  const InstanceEditorPage({super.key, this.existing});

  final OpenProjectInstance? existing;

  @override
  void onCreate(BuildContext context, InstanceEditorBloc bloc) {
    super.onCreate(context, bloc);
    bloc.init(existing: existing);
  }

  @override
  void onEffect(BuildContext context, InstanceEditorEffect effect) {
    // Effects are consumed by [_InstanceEditorForm] which owns the
    // [TextEditingController]s that need to be hydrated. Nothing to do
    // at the page level.
  }

  @override
  Widget buildState(BuildContext context, InstanceEditorState state) {
    return _InstanceEditorForm(state: state);
  }
}

/// Stateful child that owns the [TextEditingController]s so they can be
/// disposed when the page is popped. Subscribes directly to
/// [InstanceEditorBloc.effectStream] to receive hydration and validation
/// effects without having to route through the parent [EffectBlocPage].
class _InstanceEditorForm extends StatefulWidget {
  const _InstanceEditorForm({required this.state});

  final InstanceEditorState state;

  @override
  State<_InstanceEditorForm> createState() => _InstanceEditorFormState();
}

class _InstanceEditorFormState extends State<_InstanceEditorForm> {
  final _labelController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _clientIdController = TextEditingController();

  StreamSubscription<InstanceEditorEffect>? _effectSubscription;

  @override
  void initState() {
    super.initState();
    // Prime the fields with the initial state (covers the case where
    // the hydrate effect was already emitted before this widget
    // subscribed).
    _syncFromState(widget.state);
    _effectSubscription = context
        .read<InstanceEditorBloc>()
        .effectStream
        .listen(_handleEffect);
  }

  @override
  void dispose() {
    _effectSubscription?.cancel();
    _labelController.dispose();
    _baseUrlController.dispose();
    _clientIdController.dispose();
    super.dispose();
  }

  void _syncFromState(InstanceEditorState state) {
    if (_labelController.text != state.label) {
      _labelController.text = state.label;
    }
    if (_baseUrlController.text != state.baseUrl) {
      _baseUrlController.text = state.baseUrl;
    }
    if (_clientIdController.text != state.clientId) {
      _clientIdController.text = state.clientId;
    }
  }

  void _handleEffect(InstanceEditorEffect effect) {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    effect.when(
      hydrate: (label, baseUrl, clientId) {
        if (_labelController.text != label) _labelController.text = label;
        if (_baseUrlController.text != baseUrl) {
          _baseUrlController.text = baseUrl;
        }
        if (_clientIdController.text != clientId) {
          _clientIdController.text = clientId;
        }
      },
      invalidLabel: () => _snack(l10n.instance_editor_invalid_label),
      invalidUrl: () => _snack(l10n.instance_configuration__invalid_url),
      invalidClientId: () => _snack(l10n.instance_editor_invalid_client_id),
      saved: (_) => Navigator.of(context).pop(),
      createdAndNeedsAuth: (instanceId) => _handleCreatedAndNeedsAuth(
        instanceId,
      ),
    );
  }

  /// Orchestrates the post-create flow:
  ///   1. Switch to the freshly-created instance (via [InstanceSwitcher]
  ///      so the timer guard is respected).
  ///   2. If a timer was running on the previous instance, prompt the
  ///      user to save / discard / cancel before force-switching.
  ///   3. Kick off OAuth on the (now active) new instance so the user
  ///      is authenticated immediately after configuring it.
  /// Runs asynchronously from [_handleEffect] — the widget may be
  /// unmounted at any await point, hence the repeated `mounted` checks.
  Future<void> _handleCreatedAndNeedsAuth(String instanceId) async {
    final navigator = Navigator.of(context);
    final switcher = inject<InstanceSwitcher>();
    final authService = inject<AuthService>(instanceName: 'openProject');

    final InstanceSwitchResult result;
    try {
      result = await switcher.switchTo(instanceId);
    } catch (e) {
      debugPrint('Post-create switch failed for $instanceId: $e');
      if (!mounted) return;
      _snack(AppLocalizations.of(context).generic_error);
      navigator.pop();
      return;
    }
    if (!mounted) return;

    if (result == InstanceSwitchResult.blockedByActiveTimer) {
      final decision = await TimerSwitchPrompt.show(context: context);
      if (!mounted) return;
      switch (decision) {
        case null:
        case TimerSwitchDecision.cancel:
          // User backed out; the new instance is created but not
          // active. Pop the editor so the user lands on wherever they
          // were before. They can activate + authenticate later from
          // the instances list.
          navigator.pop();
          return;
        case TimerSwitchDecision.discard:
          try {
            await switcher.switchTo(instanceId, force: true);
          } catch (e) {
            debugPrint('Post-create force switch failed for $instanceId: $e');
            if (!mounted) return;
            _snack(AppLocalizations.of(context).generic_error);
            navigator.pop();
            return;
          }
          if (!mounted) return;
          break;
        case TimerSwitchDecision.save:
          // Route to the summary page so the running timer can be
          // committed. Pop the editor first so the summary page is
          // reachable without a stack under it. The captured
          // [navigator] outlives the editor route — its own
          // BuildContext stays valid, so pushing the summary through
          // it after pop is safe.
          navigator.pop();
          // ignore: use_build_context_synchronously
          final saved = await AppRouter.routeToTimeEntrySummary(
            navigator.context,
          );
          if (saved != null) {
            await switcher.switchTo(instanceId, force: true);
            await authService.login();
          }
          return;
      }
    }

    // Launch OAuth for the new (now-active) instance. Awaiting keeps
    // the editor visible while the OS browser overlay is open, then
    // pops it once the flow settles (success, failure, or user
    // cancel — [AuthService.login] never throws). The AppRouter
    // reacts to the resulting auth-state emission and routes forward.
    await authService.login();
    if (!mounted) return;
    navigator.pop();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = widget.state;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          state.isEditing
              ? l10n.instance_editor_edit_title
              : l10n.instance_editor_add_title,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              child: Column(
                children: [
                  TextFormField(
                    controller: _labelController,
                    decoration: InputDecoration(
                      labelText: l10n.instance_editor_label,
                      hintText: l10n.instance_editor_label_hint,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _baseUrlController,
                    keyboardType: TextInputType.url,
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelText: l10n.instance_configuration_base_url,
                      hintText: 'https://openproject.example.com',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _clientIdController,
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelText: l10n.instance_configuration_client_id,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (state.isEditing) ...[
              Text(
                l10n.instance_editor_reauth_notice,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: FilledButton(
                onPressed: () {
                  context.read<InstanceEditorBloc>().save(
                    label: _labelController.text,
                    baseUrl: _baseUrlController.text,
                    clientId: _clientIdController.text,
                  );
                },
                text: l10n.generic_save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
