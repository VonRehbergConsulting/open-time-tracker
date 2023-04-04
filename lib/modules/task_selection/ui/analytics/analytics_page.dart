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
      ),
      body: state.when(
        loading: () => const Center(child: ActivityIndicator()),
        idle: (
          dailyHours,
          projectHours,
        ) =>
            Container(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
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
    );
  }
}
