import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/l10n/app_localizations.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc_page.dart';
import 'package:open_project_time_tracker/app/ui/widgets/screens/scrollable_screen.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/export_report/export_report_bloc.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/projects_repository.dart';
import 'package:intl/intl.dart';

class ExportReportPage
    extends
        EffectBlocPage<
          ExportReportBloc,
          ExportReportState,
          ExportReportEffect
        > {
  const ExportReportPage({super.key});

  @override
  void onEffect(BuildContext context, ExportReportEffect effect) {
    effect.when(
      success: (message) {
        final snackBar = SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
      error: (message) {
        final snackBar = SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
    );
  }

  @override
  Widget buildState(BuildContext context, ExportReportState state) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dateFormat = DateFormat.yMd(locale);

    return SliverScreen(
      title: AppLocalizations.of(context).export_report_title,
      body: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8.0),
            // Date range selection
            Card(
              clipBehavior: Clip.hardEdge,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(18.0)),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).export_report_date_range,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Start date
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: state.startDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color.fromRGBO(38, 92, 185, 1),
                                  surface: Colors.white,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (date != null && context.mounted) {
                          context.read<ExportReportBloc>().setStartDate(date);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(
                                context,
                              ).export_report_start_date,
                            ),
                            Text(
                              dateFormat.format(state.startDate),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // End date
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: state.endDate,
                          firstDate: state.startDate,
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color.fromRGBO(38, 92, 185, 1),
                                  surface: Colors.white,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (date != null && context.mounted) {
                          context.read<ExportReportBloc>().setEndDate(date);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(
                                context,
                              ).export_report_end_date,
                            ),
                            Text(
                              dateFormat.format(state.endDate),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Project filter (optional)
            Card(
              clipBehavior: Clip.hardEdge,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(18.0)),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).export_report_project_filter,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Project multiselect with chips
                    if (state.isLoadingProjects)
                      const Center(child: CircularProgressIndicator())
                    else if (state.availableProjects.isEmpty)
                      Text(
                        AppLocalizations.of(context).export_report_no_projects,
                        style: TextStyle(color: Colors.grey[600]),
                      )
                    else
                      _ProjectMultiSelect(
                        availableProjects: state.availableProjects,
                        selectedProjects: state.selectedProjects,
                        onChanged: (projects) {
                          context
                              .read<ExportReportBloc>()
                              .setSelectedProjects(projects);
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Export format selection
            Card(
              clipBehavior: Clip.hardEdge,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(18.0)),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).export_report_format,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // XLSX button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: state.isExporting
                            ? null
                            : () => context
                                  .read<ExportReportBloc>()
                                  .exportAsExcel(),
                        icon: const Icon(Icons.table_chart),
                        label: Text(
                          AppLocalizations.of(context).export_report_xlsx,
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: const Color.fromRGBO(38, 92, 185, 1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // PDF button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: state.isExporting
                            ? null
                            : () => context
                                  .read<ExportReportBloc>()
                                  .exportAsPdf(),
                        icon: const Icon(Icons.picture_as_pdf),
                        label: Text(
                          AppLocalizations.of(context).export_report_pdf,
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: const Color.fromRGBO(38, 92, 185, 1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),

                    if (state.isExporting) ...[
                      const SizedBox(height: 16),
                      const Center(child: CircularProgressIndicator()),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}

class _ProjectMultiSelect extends StatefulWidget {
  final List<Project> availableProjects;
  final List<Project> selectedProjects;
  final void Function(List<Project>) onChanged;

  const _ProjectMultiSelect({
    required this.availableProjects,
    required this.selectedProjects,
    required this.onChanged,
  });

  @override
  State<_ProjectMultiSelect> createState() => _ProjectMultiSelectState();
}

class _ProjectMultiSelectState extends State<_ProjectMultiSelect> {
  final TextEditingController _searchController = TextEditingController();
  List<Project> _filteredProjects = [];
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _filteredProjects = widget.availableProjects;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _removeOverlay,
              child: const SizedBox.expand(),
            ),
          ),
          Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0.0, size.height + 5.0),
              child: Material(
                elevation: 4.0,
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: StatefulBuilder(
                    builder: (context, setOverlayState) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Search field
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              8.0,
                              8.0,
                              8.0,
                              0,
                            ),
                            child: TextField(
                              controller: _searchController,
                              autofocus: true,
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(
                                  context,
                                ).export_report_search_projects,
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                isDense: true,
                              ),
                              onChanged: (value) {
                                setOverlayState(() {
                                  if (value.isEmpty) {
                                    _filteredProjects =
                                        widget.availableProjects;
                                  } else {
                                    _filteredProjects = widget.availableProjects
                                        .where(
                                          (p) => p.title.toLowerCase().contains(
                                            value.toLowerCase(),
                                          ),
                                        )
                                        .toList();
                                  }
                                });
                              },
                            ),
                          ),
                          const Divider(height: 1, thickness: 1),
                          // Project list
                          Flexible(
                            child: ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: _filteredProjects.length,
                              itemBuilder: (context, index) {
                                final project = _filteredProjects[index];
                                final isSelected = widget.selectedProjects.any(
                                  (p) => p.id == project.id,
                                );
                                return ListTile(
                                  dense: true,
                                  title: Text(project.title),
                                  trailing: isSelected
                                      ? const Icon(
                                          Icons.check_circle,
                                          color: Color.fromRGBO(38, 92, 185, 1),
                                        )
                                      : null,
                                  onTap: () {
                                    final newSelection = List<Project>.from(
                                      widget.selectedProjects,
                                    );
                                    if (isSelected) {
                                      newSelection.removeWhere(
                                        (p) => p.id == project.id,
                                      );
                                    } else {
                                      newSelection.add(project);
                                    }
                                    widget.onChanged(newSelection);
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        onTap: () {
          if (_overlayEntry == null) {
            _showOverlay();
          } else {
            _removeOverlay();
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: AppLocalizations.of(
              context,
            ).export_report_select_projects,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          child: widget.selectedProjects.isEmpty
              ? Text(
                  AppLocalizations.of(context).export_report_all_projects,
                  style: TextStyle(color: Colors.grey[600]),
                )
              : Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: widget.selectedProjects.map((project) {
                    return Chip(
                      label: Text(
                        project.title,
                        style: const TextStyle(fontSize: 12),
                      ),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        final newSelection = List<Project>.from(
                          widget.selectedProjects,
                        );
                        newSelection.removeWhere((p) => p.id == project.id);
                        widget.onChanged(newSelection);
                      },
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 0,
                      ),
                      backgroundColor: Colors.blue.shade50,
                      labelStyle: TextStyle(color: Colors.blue.shade900),
                    );
                  }).toList(),
                ),
        ),
      ),
    );
  }
}
