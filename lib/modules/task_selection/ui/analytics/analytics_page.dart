import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/l10n/app_localizations.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc_page.dart';
import 'package:open_project_time_tracker/app/ui/widgets/configured_shimmer.dart';
import 'package:open_project_time_tracker/app/ui/widgets/screens/scrollable_screen.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/analytics/analytics_bloc.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/analytics/widgets/daily_work_chart.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/analytics/widgets/projects_chart.dart';

class AnalyticsPage extends BlocPage<AnalyticsBloc, AnaliticsState> {
  const AnalyticsPage({super.key});

  @override
  void onCreate(BuildContext context, AnalyticsBloc bloc) {
    super.onCreate(context, bloc);
    bloc.reload();
  }

  @override
  Widget buildState(BuildContext context, AnaliticsState state) {
    return SliverScreen(
      title: AppLocalizations.of(context).analytics_title,
      onRefresh: context.read<AnalyticsBloc>().reload,
      scrollingEnabled: state.maybeWhen(
        loading: () => false,
        orElse: () => true,
      ),
      body: state.when(
        loading: () => SliverToBoxAdapter(
          child: ConfiguredShimmer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8.0),
                DailyWorkChart(
                  data: DailyWorkChartData(
                    monday: const Duration(hours: 8),
                    tuesday: const Duration(hours: 8),
                    wednesday: const Duration(hours: 8),
                    thursday: const Duration(hours: 8),
                    friday: const Duration(hours: 8),
                    saturday: const Duration(hours: 8),
                    sunday: const Duration(hours: 8),
                  ),
                ),
                const SizedBox(height: 16.0),
                ProjectsChart(
                  items: [
                    ProjectChartData(
                      title: 'Title',
                      duration: const Duration(hours: 8),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        idle: (dailyHours, projectHours) => projectHours.isEmpty
            ? SliverScreenEmpty(
                text: AppLocalizations.of(context).analytics_empty,
              )
            : SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8.0),
                    DailyWorkChart(
                      data: DailyWorkChartData(
                        monday: dailyHours.monday,
                        tuesday: dailyHours.tuesday,
                        wednesday: dailyHours.wednesday,
                        thursday: dailyHours.thursday,
                        friday: dailyHours.friday,
                        saturday: dailyHours.saturday,
                        sunday: dailyHours.sunday,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    ProjectsChart(
                      items: projectHours
                          .map(
                            (item) => ProjectChartData(
                              title: item.title,
                              duration: item.duration,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
