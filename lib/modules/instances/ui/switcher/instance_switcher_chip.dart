import 'dart:async';

import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/app/app_router.dart';
import 'package:open_project_time_tracker/app/di/inject.dart';
import 'package:open_project_time_tracker/app/instances/domain/instance_switcher.dart';
import 'package:open_project_time_tracker/app/instances/domain/instances_repository.dart';
import 'package:open_project_time_tracker/app/instances/domain/open_project_instance.dart';
import 'package:open_project_time_tracker/l10n/app_localizations.dart';
import 'package:open_project_time_tracker/modules/instances/ui/switcher/timer_switch_prompt.dart';

/// Small chip shown in the top app bar that displays the currently
/// active OpenProject instance's label. Tapping it opens a bottom
/// sheet listing all instances so the user can switch or open the
/// full management screen.
class InstanceSwitcherChip extends StatefulWidget {
  const InstanceSwitcherChip({super.key});

  @override
  State<InstanceSwitcherChip> createState() => _InstanceSwitcherChipState();
}

class _InstanceSwitcherChipState extends State<InstanceSwitcherChip> {
  late final InstancesRepository _repository;
  late final Stream<InstancesSnapshot> _stream;

  @override
  void initState() {
    super.initState();
    _repository = inject<InstancesRepository>();
    _stream = _repository.observe();
    // Kick off an initial snapshot load. Deliberately fire-and-forget:
    // the StreamBuilder below will render the current cached snapshot
    // synchronously and rebuild once load() resolves. `unawaited` makes
    // this intent explicit and satisfies `unawaited_futures` should
    // this method ever become async.
    unawaited(_repository.load());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<InstancesSnapshot>(
      stream: _stream,
      initialData: _repository.current,
      builder: (context, snap) {
        final snapshot = snap.data ?? _repository.current;
        // Hide the chip when only one (or zero) instance exists —
        // switching serves no purpose and the app-bar stays cleaner.
        if (snapshot.instances.length < 2) {
          return const SizedBox.shrink();
        }
        final active = snapshot.activeInstance;
        final label = active?.label ?? '?';
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ActionChip(
            avatar: const Icon(Icons.dns_outlined, size: 18),
            label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            onPressed: () => _showSwitcher(context, snapshot),
          ),
        );
      },
    );
  }

  Future<void> _showSwitcher(
    BuildContext context,
    InstancesSnapshot snapshot,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(child: _SwitcherSheet(snapshot: snapshot));
      },
    );
  }
}

class _SwitcherSheet extends StatelessWidget {
  const _SwitcherSheet({required this.snapshot});

  final InstancesSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
          child: Row(
            children: [
              Text(
                l10n.instances_switcher_title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  AppRouter.routeToInstances(context);
                },
                icon: const Icon(Icons.settings_outlined, size: 18),
                label: Text(l10n.instances_switcher_manage),
              ),
            ],
          ),
        ),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.instances.length,
            itemBuilder: (context, index) {
              final instance = snapshot.instances[index];
              final isActive = instance.id == snapshot.activeInstanceId;
              return ListTile(
                leading: Icon(
                  isActive ? Icons.check_circle : Icons.circle_outlined,
                  color: isActive
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                title: Text(instance.label),
                subtitle: Text(
                  instance.baseUrl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: isActive ? null : () => _handleSelect(context, instance),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Future<void> _handleSelect(
    BuildContext context,
    OpenProjectInstance instance,
  ) async {
    final switcher = inject<InstanceSwitcher>();
    final sheetNavigator = Navigator.of(context);
    final result = await switcher.switchTo(instance.id);
    if (result != InstanceSwitchResult.blockedByActiveTimer) {
      sheetNavigator.pop();
      return;
    }

    if (!context.mounted) return;
    final decision = await TimerSwitchPrompt.show(context: context);
    if (decision == null) return;

    switch (decision) {
      case TimerSwitchDecision.cancel:
        return;
      case TimerSwitchDecision.discard:
        await switcher.switchTo(instance.id, force: true);
        sheetNavigator.pop();
        return;
      case TimerSwitchDecision.save:
        if (!context.mounted) return;
        // Close the sheet before routing to the summary so the user
        // sees the summary page unobstructed.
        sheetNavigator.pop();
        // Opt out of the active-timer redirect: the whole point of
        // this branch is to save the currently running timer via the
        // summary page. Without this flag routeToTimeEntrySummary
        // would bounce us back to the timer page and the save could
        // never complete.
        final saved = await AppRouter.routeToTimeEntrySummary(
          context,
          skipActiveTimerRedirect: true,
        );
        if (saved != null) {
          await switcher.switchTo(instance.id, force: true);
        }
        return;
    }
  }
}
