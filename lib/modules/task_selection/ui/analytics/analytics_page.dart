import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc_page.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/analytics/analytics_bloc.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/analytics/widgets/daily_work_chart.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/analytics/widgets/projects_chart.dart';

import '../../../../app/ui/widgets/activity_indicator.dart';

class AnalyticsPage extends BlocPage<AnalyticsBloc, AnaliticsState> {
  const AnalyticsPage({super.key});

  @override
  void onCreate(BuildContext context, AnalyticsBloc bloc) {
    super.onCreate(context, bloc);
    bloc.reload();
  }

  @override
  Widget buildState(BuildContext context, AnaliticsState state) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).analytics_title),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: state.when(
        loading: () => const Center(child: ActivityIndicator()),
        idle: (
          dailyHours,
          projectHours,
        ) =>
            dailyHours.isEmpty
                ? Center(
                    child: Text(
                      AppLocalizations.of(context).analytics_empty,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: context.read<AnalyticsBloc>().reload,
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(
                                height: 8.0,
                              ),
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
                              const SizedBox(
                                height: 16.0,
                              ),
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
                    ),
                  ),
      ),
    );
  }
}
