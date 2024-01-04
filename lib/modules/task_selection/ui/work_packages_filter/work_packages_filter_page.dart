import 'package:flutter/material.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc_page.dart';
import 'package:open_project_time_tracker/app/ui/widgets/activity_indicator.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/work_packages_filter/work_packages_filter_bloc.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WorkPackagesFilterPage extends EffectBlocPage<WorkPackagesFilterBloc,
    WorkpackagesFilterState, WorkPackagesFilterEffect> {
  final Function()? completion;

  const WorkPackagesFilterPage({
    super.key,
    this.completion,
  });

  @override
  void onEffect(BuildContext context, WorkPackagesFilterEffect effect) {
    effect.when(
      complete: () {
        if (completion != null) {
          completion!();
        }
        Navigator.of(context).maybePop();
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
  void onCreate(BuildContext context, WorkPackagesFilterBloc bloc) {
    super.onCreate(context, bloc);
    bloc.reload();
  }

  @override
  Widget buildState(BuildContext context, WorkpackagesFilterState state) {
    return Scaffold(
      body: CustomScrollView(
        physics: state.whenOrNull(
          loading: () => const NeverScrollableScrollPhysics(),
        ),
        slivers: [
          SliverAppBar(
            title:
                Text(AppLocalizations.of(context).work_packages_filter__title),
            actions: [
              IconButton(
                onPressed: context.read<WorkPackagesFilterBloc>().submit,
                icon: const Icon(Icons.done),
              ),
            ],
          ),
          ...state.when<List<Widget>>(
            loading: () => [
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: ActivityIndicator(),
                ),
              ),
            ],
            selection: (
              statuses,
              selectedIds,
            ) =>
                [
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final status = statuses[index];
                      return _item(
                        context,
                        isSelected: selectedIds.contains(status.id),
                        text: status.name,
                        onToggle: () => context
                            .read<WorkPackagesFilterBloc>()
                            .toggleSelection(status.id),
                      );
                    },
                    childCount: statuses.length,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context, {
    required bool isSelected,
    required String text,
    required void Function() onToggle,
  }) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              MSHCheckbox(
                value: isSelected,
                onChanged: (value) => onToggle(),
                size: 24.0,
                style: MSHCheckboxStyle.fillScaleCheck,
                colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
                  checkedColor: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 16.0),
              Text(text),
            ],
          ),
        ),
      ),
    );
  }
}
