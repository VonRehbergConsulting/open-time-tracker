import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/app/app_router.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc.dart';
import 'package:open_project_time_tracker/extensions/duration.dart';
import 'package:open_project_time_tracker/modules/timer/ui/timer/timer_bloc.dart';

class MiniTimerWidget extends StatefulWidget {
  const MiniTimerWidget({super.key});

  @override
  State<MiniTimerWidget> createState() => _MiniTimerWidgetState();
}

class _MiniTimerWidgetState extends State<MiniTimerWidget> {
  @override
  Widget build(BuildContext context) {
    return InjectableBlocConsumer<TimerBloc, TimerState>(
      onCreate: (_, bloc) => bloc.updateState(),
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final theme = Theme.of(context);
            final isCompact = constraints.maxWidth < 390;
            final isVeryCompact = constraints.maxWidth < 345;

            final outerHorizontalPadding = isCompact ? 10.0 : 14.0;
            final outerBottomPadding = isCompact ? 10.0 : 14.0;
            final innerHorizontalPadding = isCompact ? 12.0 : 16.0;
            final innerVerticalPadding = isCompact ? 10.0 : 12.0;
            final borderRadius = isCompact ? 14.0 : 16.0;
            final spacing = isCompact ? 10.0 : 12.0;
            final iconSize = isCompact ? 22.0 : 26.0;

            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  outerHorizontalPadding,
                  0,
                  outerHorizontalPadding,
                  outerBottomPadding,
                ),
                child: Material(
                  color: theme.scaffoldBackgroundColor,
                  elevation: 4,
                  shadowColor: theme.colorScheme.shadow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(borderRadius),
                    onTap: () => AppRouter.routeToTimer(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: innerHorizontalPadding,
                        vertical: innerVerticalPadding,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.timer_outlined, size: iconSize),
                          SizedBox(width: spacing),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  state.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium,
                                ),
                                if (!isVeryCompact)
                                  Text(
                                    state.subtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(width: spacing),
                          Text(
                            state.timeSpent.longWatch(),
                            style: theme.textTheme.titleMedium,
                          ),
                          SizedBox(width: isCompact ? 6 : 8),
                          Icon(
                            Icons.keyboard_arrow_up_rounded,
                            size: isCompact ? 22 : 26,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
