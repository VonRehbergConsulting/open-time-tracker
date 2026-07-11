import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:open_project_time_tracker/app/di/inject.dart';
import 'package:open_project_time_tracker/app/navigation/app_authorized_router_bloc.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc.dart';
import 'package:open_project_time_tracker/app/ui/widgets/mini_timer_widget.dart';
import 'package:open_project_time_tracker/app/ui/widgets/splash_screen.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/time_entries_list/time_entries_list_page.dart';

/// Fallback rendered height of [MiniTimerWidget] used only for the very
/// first frame before its real size is measured. After first layout,
/// [_MeasureSize] reports the actual height and the inset is updated so
/// SnackBars / FABs are always positioned correctly, regardless of text
/// scale or platform padding.
const double _kMiniTimerFallbackHeight = 84.0;

class AppAuthorizedRouter extends StatefulWidget {
  const AppAuthorizedRouter({super.key});

  @override
  State<AppAuthorizedRouter> createState() => _AppAuthorizedRouterState();
}

class _AppAuthorizedRouterState extends State<AppAuthorizedRouter> {
  double _miniTimerHeight = _kMiniTimerFallbackHeight;

  void _handleMiniTimerSize(Size size) {
    // The callback is scheduled via addPostFrameCallback from
    // _MeasureSize's render object; by the time it fires this State
    // may have been disposed (e.g. an instance switch remounted the
    // whole authorized subtree between layout and post-frame). Guard
    // against setState-after-dispose.
    if (!mounted) return;
    // Debounce sub-pixel jitter caused by e.g. animated font metrics.
    if ((size.height - _miniTimerHeight).abs() < 0.5) return;
    setState(() => _miniTimerHeight = size.height);
  }

  @override
  Widget build(BuildContext context) {
    return InjectableBlocConsumer<
      AppAuthorizedRouterBloc,
      AppAuthorizedRouterState
    >(
      create: (context) =>
          AppAuthorizedRouterBloc(() => inject())..init(),
      builder: (context, state) {
        return state.when(
          initializing: () => const SplashScreen(),
          idle: (isTimerSet) {
            final page = isTimerSet
                ? _MiniTimerInset(
                    reservedBottom: _miniTimerHeight,
                    child: const TimeEntriesListPage(),
                  )
                : const TimeEntriesListPage();

            return Stack(
              children: [
                page,
                if (isTimerSet)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: _MeasureSize(
                      onChange: _handleMiniTimerSize,
                      child: const MiniTimerWidget(),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Injects extra bottom [MediaQuery.padding] into [child] so that
/// Scaffold-driven UI (FAB, SnackBars, safe insets) accounts for the
/// space occupied by the overlaid mini-timer widget.
class _MiniTimerInset extends StatelessWidget {
  const _MiniTimerInset({required this.reservedBottom, required this.child});

  final double reservedBottom;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return MediaQuery(
      data: mediaQuery.copyWith(
        padding: mediaQuery.padding.copyWith(
          bottom: mediaQuery.padding.bottom + reservedBottom,
        ),
      ),
      child: child,
    );
  }
}

/// Reports the rendered size of [child] to [onChange] after every layout
/// pass in which the size differs from the previous one. Callback is
/// scheduled in a post-frame callback so it is safe to call [setState].
class _MeasureSize extends SingleChildRenderObjectWidget {
  const _MeasureSize({required this.onChange, required Widget super.child});

  final ValueChanged<Size> onChange;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _MeasureSizeRenderObject(onChange);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _MeasureSizeRenderObject renderObject,
  ) {
    renderObject.onChange = onChange;
  }
}

class _MeasureSizeRenderObject extends RenderProxyBox {
  _MeasureSizeRenderObject(this.onChange);

  ValueChanged<Size> onChange;
  Size? _lastReportedSize;

  @override
  void performLayout() {
    super.performLayout();
    final newSize = child?.size ?? Size.zero;
    if (newSize == _lastReportedSize) return;
    _lastReportedSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) => onChange(newSize));
  }
}
