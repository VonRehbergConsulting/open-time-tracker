import 'package:flutter/material.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc_page.dart';
import 'package:open_project_time_tracker/app/ui/widgets/configured_card.dart';
import 'package:open_project_time_tracker/app/ui/widgets/configured_shimmer.dart';
import 'package:open_project_time_tracker/app/ui/widgets/screens/scrollable_screen.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/work_packages_filter/work_packages_filter_bloc.dart';
import 'package:open_project_time_tracker/l10n/app_localizations.dart';

class WorkPackagesFilterPage
    extends
        EffectBlocPage<
          WorkPackagesFilterBloc,
          WorkpackagesFilterState,
          WorkPackagesFilterEffect
        > {
  final Function()? completion;

  const WorkPackagesFilterPage({super.key, this.completion});

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
    return SliverScreen(
      backgroundColor: Colors.white,
      title: AppLocalizations.of(context).work_packages_filter__title,
      actions: [
        IconButton(
          onPressed: context.read<WorkPackagesFilterBloc>().submit,
          icon: const Icon(Icons.done),
        ),
      ],
      scrollingEnabled: state.maybeWhen(
        loading: () => false,
        orElse: () => true,
      ),
      body: state.when(
        loading: () => SliverToBoxAdapter(
          child: ConfiguredShimmer(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _headerPlaceholder(),
                  _itemPlaceholder(),
                  _itemPlaceholder(),
                  const SizedBox(height: 16.0),
                  _headerPlaceholder(),
                  _itemPlaceholder(),
                  _itemPlaceholder(),
                  _itemPlaceholder(),
                  _itemPlaceholder(),
                  _itemPlaceholder(),
                  _itemPlaceholder(),
                  _itemPlaceholder(),
                ],
              ),
            ),
          ),
        ),
        selection: (statuses, selectedIds, assigneeFilter) => SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          sliver: SliverMainAxisGroup(
            slivers: [
              _header('Assignee'),
              SliverToBoxAdapter(
                child: _item(
                  context,
                  isSelected: assigneeFilter == 0,
                  text: 'Me',
                  onToggle: () => context
                      .read<WorkPackagesFilterBloc>()
                      .setAssigneeFilter(0),
                ),
              ),
              SliverToBoxAdapter(
                child: _item(
                  context,
                  isSelected: assigneeFilter == 1,
                  text: 'Everyone',
                  onToggle: () => context
                      .read<WorkPackagesFilterBloc>()
                      .setAssigneeFilter(1),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
              _header('Status'),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final status = statuses[index];
                  return _item(
                    context,
                    isSelected: selectedIds.contains(status.id),
                    text: status.name,
                    onToggle: () => context
                        .read<WorkPackagesFilterBloc>()
                        .toggleStatusSelection(status.id),
                  );
                }, childCount: statuses.length),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerPlaceholder() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        margin: EdgeInsets.all(0),
        child: Text(
          'Filter title placeholder',
          style: TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }

  Widget _itemPlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MSHCheckbox(
            value: true,
            onChanged: (bool selected) {},
            style: MSHCheckboxStyle.fillScaleCheck,
            size: 24.0,
          ),
          const SizedBox(width: 16.0),
          const ConfiguredCard(child: Text('Filter option placeholder')),
        ],
      ),
    );
  }

  Widget _header(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(title, style: const TextStyle(fontSize: 18.0)),
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
