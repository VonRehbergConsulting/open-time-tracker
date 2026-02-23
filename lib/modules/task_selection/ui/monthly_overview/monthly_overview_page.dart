import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/l10n/app_localizations.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc_page.dart';
import 'package:open_project_time_tracker/app/ui/widgets/configured_shimmer.dart';
import 'package:open_project_time_tracker/app/ui/widgets/screens/scrollable_screen.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/monthly_overview/monthly_overview_bloc.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/monthly_overview/widgets/monthly_calendar_widget.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/analytics/widgets/daily_work_chart.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/analytics/widgets/projects_chart.dart';

class MonthlyOverviewPage extends BlocPage<MonthlyOverviewBloc, MonthlyOverviewState> {
  const MonthlyOverviewPage({super.key});

  @override
  void onCreate(BuildContext context, MonthlyOverviewBloc bloc) {
    super.onCreate(context, bloc);
    bloc.reload();
  }

  @override
  Widget buildState(BuildContext context, MonthlyOverviewState state) {
    return SliverScreen(
      title: AppLocalizations.of(context).monthly_overview_title,
      onRefresh: context.read<MonthlyOverviewBloc>().reload,
      scrollingEnabled: state.maybeWhen(
        loading: (_) => false,
        orElse: () => true,
      ),
      body: state.when(
        loading: (viewMode) => SliverToBoxAdapter(
          child: Center(
            child: ConfiguredShimmer(
              child: viewMode == ViewMode.monthly
                  ? const MonthlyCalendarWidget(
                      year: 2024,
                      month: 1,
                      dailyHours: {},
                      weeklyHours: {},
                    )
                  : Column(
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
                              title: 'Project',
                              duration: const Duration(hours: 8),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
        ),
        loaded: (year, month, dailyHours, weeklyHours, weekdayHours, projectHours, viewMode) => SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8.0),
              // View mode toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _ViewModeButton(
                        label: AppLocalizations.of(context).monthly_overview_weekly,
                        icon: Icons.view_week,
                        isSelected: viewMode == ViewMode.weekly,
                        onTap: () => context.read<MonthlyOverviewBloc>().toggleViewMode(ViewMode.weekly),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ViewModeButton(
                        label: AppLocalizations.of(context).monthly_overview_monthly,
                        icon: Icons.calendar_month,
                        isSelected: viewMode == ViewMode.monthly,
                        onTap: () => context.read<MonthlyOverviewBloc>().toggleViewMode(ViewMode.monthly),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              // Display appropriate view
              if (viewMode == ViewMode.monthly)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MonthlyCalendarWidget(
                      year: year,
                      month: month,
                      dailyHours: dailyHours,
                      weeklyHours: weeklyHours,
                      onMonthChanged: (newYear, newMonth) {
                        context.read<MonthlyOverviewBloc>().changeMonth(newYear, newMonth);
                      },
                    ),
                    const SizedBox(height: 16.0),
                    ProjectsChart(
                      items: projectHours
                          .map((p) => ProjectChartData(
                                title: p.title,
                                duration: p.duration,
                              ))
                          .toList(),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DailyWorkChart(
                      data: DailyWorkChartData(
                        monday: weekdayHours.monday,
                        tuesday: weekdayHours.tuesday,
                        wednesday: weekdayHours.wednesday,
                        thursday: weekdayHours.thursday,
                        friday: weekdayHours.friday,
                        saturday: weekdayHours.saturday,
                        sunday: weekdayHours.sunday,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    ProjectsChart(
                      items: projectHours
                          .map((p) => ProjectChartData(
                                title: p.title,
                                duration: p.duration,
                              ))
                          .toList(),
                    ),
                  ],
                ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ViewModeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromRGBO(38, 92, 185, 1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color.fromRGBO(38, 92, 185, 1) : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
