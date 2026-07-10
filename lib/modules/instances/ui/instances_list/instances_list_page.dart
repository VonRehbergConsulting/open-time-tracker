import 'package:flutter/material.dart' hide FilledButton;
import 'package:open_project_time_tracker/app/app_router.dart';
import 'package:open_project_time_tracker/app/instances/domain/open_project_instance.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc_page.dart';
import 'package:open_project_time_tracker/l10n/app_localizations.dart';
import 'package:open_project_time_tracker/modules/instances/ui/instances_list/instances_list_bloc.dart';
import 'package:open_project_time_tracker/modules/instances/ui/switcher/timer_switch_prompt.dart';

class InstancesListPage
    extends
        EffectBlocPage<
          InstancesListBloc,
          InstancesListState,
          InstancesListEffect
        > {
  const InstancesListPage({super.key});

  @override
  void onCreate(BuildContext context, InstancesListBloc bloc) {
    super.onCreate(context, bloc);
    bloc.init();
  }

  @override
  void onEffect(BuildContext context, InstancesListEffect effect) {
    effect.when(
      switchBlockedByActiveTimer: (targetInstanceId) async {
        final decision = await TimerSwitchPrompt.show(context: context);
        if (decision == null || !context.mounted) return;
        final bloc = context.read<InstancesListBloc>();
        switch (decision) {
          case TimerSwitchDecision.cancel:
            return;
          case TimerSwitchDecision.discard:
            bloc.forceSelectInstance(targetInstanceId);
            return;
          case TimerSwitchDecision.save:
            // Save flow: route to summary page. If the user completes
            // the save, the timer is cleared server-side; if they back
            // out, we do not switch. Either way we force-switch after
            // the summary page pops with a non-null result.
            final saved = await AppRouter.routeToTimeEntrySummary(context);
            if (saved != null && context.mounted) {
              context.read<InstancesListBloc>().forceSelectInstance(
                targetInstanceId,
              );
            }
            return;
        }
      },
      error: () {
        final snackBar = SnackBar(
          content: Text(AppLocalizations.of(context).generic_error),
          duration: const Duration(seconds: 2),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
    );
  }

  @override
  Widget buildState(BuildContext context, InstancesListState state) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.instances_title)),
      body: state.when(
        idle: (instances, activeInstanceId) {
          if (instances.isEmpty) {
            return _EmptyState();
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: instances.length,
            separatorBuilder: (context, _) => const Divider(height: 0),
            itemBuilder: (context, index) {
              final instance = instances[index];
              return _InstanceTile(
                instance: instance,
                isActive: instance.id == activeInstanceId,
                onTap: () =>
                    context.read<InstancesListBloc>().selectInstance(
                      instance.id,
                    ),
                onEdit: () => AppRouter.routeToInstanceEditor(
                  context: context,
                  existing: instance,
                ),
                onDelete: () => _confirmAndDelete(context, instance),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AppRouter.routeToInstanceEditor(context: context),
        icon: const Icon(Icons.add),
        label: Text(l10n.instances_add),
        // Match the app's primary CTA style (see [FilledButton]) so
        // "Add instance" reads as the same action colour as "Log in" /
        // "Save" instead of the muted M3 primaryContainer default.
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Future<void> _confirmAndDelete(
    BuildContext context,
    OpenProjectInstance instance,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.instances_delete_title),
        content: Text(
          l10n.instances_delete_description(instance.label),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.generic_no),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.generic_yes),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<InstancesListBloc>().removeInstance(instance.id);
    }
  }
}

class _InstanceTile extends StatelessWidget {
  const _InstanceTile({
    required this.instance,
    required this.isActive,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final OpenProjectInstance instance;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        isActive ? Icons.check_circle : Icons.circle_outlined,
        color: isActive ? Theme.of(context).primaryColor : Colors.grey,
      ),
      title: Text(
        instance.label,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        instance.baseUrl,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
      trailing: PopupMenuButton<_TileAction>(
        onSelected: (action) {
          switch (action) {
            case _TileAction.edit:
              onEdit();
              break;
            case _TileAction.delete:
              onDelete();
              break;
          }
        },
        itemBuilder: (context) {
          final l10n = AppLocalizations.of(context);
          return [
            PopupMenuItem(
              value: _TileAction.edit,
              child: Text(l10n.instances_edit),
            ),
            PopupMenuItem(
              value: _TileAction.delete,
              child: Text(l10n.instances_delete),
            ),
          ];
        },
      ),
    );
  }
}

enum _TileAction { edit, delete }

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.dns_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.instances_empty,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
