import 'dart:async';

import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/app/di/inject.dart';
import 'package:open_project_time_tracker/app/instances/domain/instances_repository.dart';
import 'package:open_project_time_tracker/app/navigation/app_router_bloc.dart';
import 'package:open_project_time_tracker/app/navigation/app_authorized_router.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc.dart';
import 'package:open_project_time_tracker/app/ui/widgets/error_screen.dart';
import 'package:open_project_time_tracker/app/ui/widgets/splash_screen.dart';
import 'package:open_project_time_tracker/modules/authorization/ui/authorization/authorization_page.dart';
import 'package:open_project_time_tracker/l10n/app_localizations.dart';

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  @override
  Widget build(BuildContext context) {
    return InjectableBlocConsumer<AppRouterBloc, AppRouterState>(
      create: (context) => AppRouterBloc(
        () => inject(instanceName: 'openProject'),
        () => inject(),
        () => inject(instanceName: 'openProject'),
        () => inject(),
      )..init(),
      builder: (context, state) {
        return state.when(
          loading: () => const SplashScreen(),
          authorized: () => const _KeyedAuthorizedRouter(),
          unaurhorized: () => const AuthorizationPage(),
          error: () => ErrorScreen(
            text: AppLocalizations.of(context).generic_error,
            buttonText: AppLocalizations.of(context).generic_retry,
            action: () async {
              await context.read<AppRouterBloc>().retryAuthorization();
              setState(() {});
            },
          ),
        );
      },
    );
  }
}

/// Wraps [AppAuthorizedRouter] with a [ValueKey] derived from the
/// currently active OpenProject instance id.
///
/// This is what makes an instance switch actually take effect: when the
/// key changes, Flutter's element diff treats it as a different widget
/// at the same slot, unmounts the previous [AppAuthorizedRouter]
/// element (dropping `AppAuthorizedRouterBloc`, `TimeEntriesListBloc`
/// and every other `@injectable` bloc below it), and mounts a fresh
/// one. Those fresh blocs re-fetch on init, so no data cached for the
/// previous tenant remains visible.
///
/// Uses an explicit [StreamSubscription] rather than a [StreamBuilder]
/// because the latter's `didUpdateWidget` re-subscription behaviour
/// interacts badly with rxdart's `BehaviorSubject.stream` returning a
/// fresh wrapper on each access: parent rebuilds during the
/// switch-in-progress window (there are several, driven by the timer
/// stream and the auth stream) could cancel the old subscription
/// before it delivered the pending snapshot, and although the new
/// subscription would replay the current value, the intermediate
/// build could reference a stale one. Owning the subscription in a
/// [State] guarantees exactly-once delivery per emit.
class _KeyedAuthorizedRouter extends StatefulWidget {
  const _KeyedAuthorizedRouter();

  @override
  State<_KeyedAuthorizedRouter> createState() => _KeyedAuthorizedRouterState();
}

class _KeyedAuthorizedRouterState extends State<_KeyedAuthorizedRouter> {
  late final InstancesRepository _repository;
  StreamSubscription<InstancesSnapshot>? _subscription;
  String? _activeId;

  @override
  void initState() {
    super.initState();
    _repository = inject<InstancesRepository>();
    _activeId = _repository.current.activeInstanceId;
    _subscription = _repository.observe().listen(_onSnapshot);
  }

  void _onSnapshot(InstancesSnapshot snapshot) {
    final next = snapshot.activeInstanceId;
    if (next == _activeId) return;
    if (!mounted) return;
    setState(() => _activeId = next);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final id = _activeId ?? '_';
    return AppAuthorizedRouter(key: ValueKey<String>('authorized:$id'));
  }
}
