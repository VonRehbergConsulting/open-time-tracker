import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/app/app_router.dart';
import 'package:open_project_time_tracker/app/di/inject.dart';
import 'package:open_project_time_tracker/app/instances/domain/instances_repository.dart';
import 'package:open_project_time_tracker/app/ui/widgets/configured_card.dart';
import 'package:open_project_time_tracker/l10n/app_localizations.dart';

/// Profile-section tile that shows the currently active OpenProject
/// instance and opens the instances manager on tap. Reads
/// [InstancesRepository] directly (no bloc) — the data is a single
/// snapshot stream owned by a lazySingleton.
class InstancesTile extends StatefulWidget {
  const InstancesTile({super.key});

  @override
  State<InstancesTile> createState() => _InstancesTileState();
}

class _InstancesTileState extends State<InstancesTile> {
  late final InstancesRepository _repository;
  late final Stream<InstancesSnapshot> _stream;

  @override
  void initState() {
    super.initState();
    _repository = inject<InstancesRepository>();
    _stream = _repository.observe();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<InstancesSnapshot>(
      stream: _stream,
      initialData: _repository.current,
      builder: (context, snap) {
        final snapshot = snap.data ?? _repository.current;
        final active = snapshot.activeInstance;
        final l10n = AppLocalizations.of(context);
        final title = active?.label ?? l10n.instances_none_active;
        final subtitle = active?.baseUrl ?? l10n.instances_manage;
        return ConfiguredCard(
          child: ListTile(
            leading: Icon(
              Icons.dns_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(title),
            subtitle: Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => AppRouter.routeToInstances(context),
          ),
        );
      },
    );
  }
}
