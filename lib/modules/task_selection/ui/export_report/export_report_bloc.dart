import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc.dart';
import 'package:open_project_time_tracker/modules/authorization/domain/user_data_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/time_entries_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/projects_repository.dart';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

part 'export_report_bloc.freezed.dart';

@freezed
class ExportReportState with _$ExportReportState {
  factory ExportReportState({
    required DateTime startDate,
    required DateTime endDate,
    required bool isExporting,
    required List<Project> selectedProjects,
    required List<Project> availableProjects,
    required bool isLoadingProjects,
  }) = _ExportReportState;
}

@freezed
class ExportReportEffect with _$ExportReportEffect {
  factory ExportReportEffect.success(String message) = _Success;
  factory ExportReportEffect.error(String message) = _Error;
}

@injectable
class ExportReportBloc extends EffectCubit<ExportReportState, ExportReportEffect> {
  final TimeEntriesRepository _timeEntriesRepository;
  final UserDataRepository _userDataRepository;
  final ProjectsRepository _projectsRepository;

  ExportReportBloc(
    this._timeEntriesRepository,
    this._userDataRepository,
    this._projectsRepository,
  ) : super(ExportReportState(
    startDate: DateTime.now().subtract(const Duration(days: 30)),
    endDate: DateTime.now(),
    isExporting: false,
    selectedProjects: [],
    availableProjects: [],
    isLoadingProjects: false,
  )) {
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    emit(state.copyWith(isLoadingProjects: true));
    try {
      final userId = await _userDataRepository.userId();
      final projects = await _projectsRepository.list(
        userId: userId.toString(),
        active: true,
        sortByName: true,
      );
      emit(state.copyWith(
        availableProjects: projects,
        isLoadingProjects: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoadingProjects: false));
    }
  }

  void toggleProject(Project project) {
    final selected = List<Project>.from(state.selectedProjects);
    if (selected.any((p) => p.id == project.id)) {
      selected.removeWhere((p) => p.id == project.id);
    } else {
      selected.add(project);
    }
    emit(state.copyWith(selectedProjects: selected));
  }

  void clearSelectedProjects() {
    emit(state.copyWith(selectedProjects: []));
  }

  void setStartDate(DateTime date) {
    emit(state.copyWith(startDate: date));
  }

  void setEndDate(DateTime date) {
    emit(state.copyWith(endDate: date));
  }

  /// Fetches and filters time entries based on date range and selected projects
  Future<List<TimeEntry>> _getFilteredTimeEntries() async {
    final userId = await _userDataRepository.userId();
    var timeEntries = await _timeEntriesRepository.list(
      userId: userId.toString(),
      startDate: state.startDate,
      endDate: state.endDate,
      fetchAll: true,
    );

    // Filter by projects if any are selected
    if (state.selectedProjects.isNotEmpty) {
      final selectedHrefs = state.selectedProjects.map((p) => p.href).toSet();
      timeEntries = timeEntries.where((entry) => 
        selectedHrefs.contains(entry.projectHref)
      ).toList();
    }

    return timeEntries;
  }

  Future<void> exportAsExcel() async {
    emit(state.copyWith(isExporting: true));
    try {
      final timeEntries = await _getFilteredTimeEntries();

      // Create Excel workbook
      final excel = Excel.createExcel();
      final sheet = excel['TimeReport'];

      // Style for header
      final headerStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#265CB9'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      );

      // Add headers
      sheet.cell(CellIndex.indexByString('A1'))
        ..value = TextCellValue('Date')
        ..cellStyle = headerStyle;
      sheet.cell(CellIndex.indexByString('B1'))
        ..value = TextCellValue('Project')
        ..cellStyle = headerStyle;
      sheet.cell(CellIndex.indexByString('C1'))
        ..value = TextCellValue('Work Package')
        ..cellStyle = headerStyle;
      sheet.cell(CellIndex.indexByString('D1'))
        ..value = TextCellValue('Hours')
        ..cellStyle = headerStyle;
      sheet.cell(CellIndex.indexByString('E1'))
        ..value = TextCellValue('Comment')
        ..cellStyle = headerStyle;

      // Add data rows
      int rowIndex = 2;
      double totalHours = 0;
      for (var entry in timeEntries) {
        final hours = entry.hours.inMinutes / 60;
        totalHours += hours;

        sheet.cell(CellIndex.indexByString('A$rowIndex'))
          .value = TextCellValue(DateFormat('dd.MM.yyyy').format(entry.spentOn));
        sheet.cell(CellIndex.indexByString('B$rowIndex'))
          .value = TextCellValue(entry.projectTitle);
        sheet.cell(CellIndex.indexByString('C$rowIndex'))
          .value = TextCellValue(entry.workPackageSubject);
        sheet.cell(CellIndex.indexByString('D$rowIndex'))
          .value = DoubleCellValue(hours);
        sheet.cell(CellIndex.indexByString('E$rowIndex'))
          .value = TextCellValue(entry.comment ?? '');
        
        rowIndex++;
      }

      // Add total row
      final totalStyle = CellStyle(bold: true);
      sheet.cell(CellIndex.indexByString('C$rowIndex'))
        ..value = TextCellValue('TOTAL')
        ..cellStyle = totalStyle;
      sheet.cell(CellIndex.indexByString('D$rowIndex'))
        ..value = DoubleCellValue(totalHours)
        ..cellStyle = totalStyle;

      // Set column widths
      sheet.setColumnWidth(0, 15);
      sheet.setColumnWidth(1, 25);
      sheet.setColumnWidth(2, 30);
      sheet.setColumnWidth(3, 10);
      sheet.setColumnWidth(4, 40);

      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final dateRange = '${DateFormat('yyyyMMdd').format(state.startDate)}_${DateFormat('yyyyMMdd').format(state.endDate)}';
      final filePath = '${directory.path}/time_report_$dateRange.xlsx';
      final file = File(filePath);
      await file.writeAsBytes(excel.encode()!);

      // Open the PDF file for preview
      final uri = Uri.file(filePath);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        emit(state.copyWith(isExporting: false));
        emitEffect(ExportReportEffect.success('PDF report opened successfully'));
      } else {
        emit(state.copyWith(isExporting: false));
        emitEffect(ExportReportEffect.error('Unable to open Excel file. Please check your file viewer settings.'));
      }
    } on DioException {
      emit(state.copyWith(isExporting: false));
      emitEffect(ExportReportEffect.error('Network error while fetching time entries. Please check your connection.'));
    } on FileSystemException {
      emit(state.copyWith(isExporting: false));
      emitEffect(ExportReportEffect.error('Failed to save Excel file. Please check storage permissions.'));
    } catch (e) {
      emit(state.copyWith(isExporting: false));
      emitEffect(ExportReportEffect.error('Failed to export Excel report. Please try again.'));
    }
  }

  Future<void> exportAsPdf() async {
    emit(state.copyWith(isExporting: true));
    try {
      final timeEntries = await _getFilteredTimeEntries();

      final pdf = pw.Document();

      // Calculate totals by project
      final Map<String, double> projectTotals = {};
      double grandTotal = 0;
      for (var entry in timeEntries) {
        final hours = entry.hours.inMinutes / 60;
        projectTotals[entry.projectTitle] = (projectTotals[entry.projectTitle] ?? 0) + hours;
        grandTotal += hours;
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            // Title
            pw.Header(
              level: 0,
              child: pw.Text(
                'Time Report',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Paragraph(
              text: 'Period: ${DateFormat('dd.MM.yyyy').format(state.startDate)} - ${DateFormat('dd.MM.yyyy').format(state.endDate)}',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 20),

            // Summary box
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total Hours:',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    '${grandTotal.toStringAsFixed(2)} h',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                // Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.blue),
                  children: [
                    _buildPdfCell('Date', isHeader: true),
                    _buildPdfCell('Project', isHeader: true),
                    _buildPdfCell('Work Package', isHeader: true),
                    _buildPdfCell('Hours', isHeader: true),
                    _buildPdfCell('Comment', isHeader: true),
                  ],
                ),
                // Data rows
                ...timeEntries.map((entry) {
                  final hours = entry.hours.inMinutes / 60;
                  return pw.TableRow(
                    children: [
                      _buildPdfCell(DateFormat('dd.MM.yyyy').format(entry.spentOn)),
                      _buildPdfCell(entry.projectTitle),
                      _buildPdfCell(entry.workPackageSubject),
                      _buildPdfCell(hours.toStringAsFixed(2)),
                      _buildPdfCell(entry.comment ?? '-'),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 20),

            // Project summary
            pw.Header(
              level: 1,
              child: pw.Text('Summary by Project'),
            ),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.blue),
                  children: [
                    _buildPdfCell('Project', isHeader: true),
                    _buildPdfCell('Total Hours', isHeader: true),
                  ],
                ),
                ...projectTotals.entries.map((entry) {
                  return pw.TableRow(
                    children: [
                      _buildPdfCell(entry.key),
                      _buildPdfCell(entry.value.toStringAsFixed(2)),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      );

      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final dateRange = '${DateFormat('yyyyMMdd').format(state.startDate)}_${DateFormat('yyyyMMdd').format(state.endDate)}';
      final filePath = '${directory.path}/time_report_$dateRange.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      // Open PDF using share sheet (iOS will show preview with option to save/share)
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Time Report ${DateFormat('dd.MM.yyyy').format(state.startDate)} - ${DateFormat('dd.MM.yyyy').format(state.endDate)}',
        sharePositionOrigin: const Rect.fromLTWH(0, 0, 100, 100),
      );

      emit(state.copyWith(isExporting: false));
      emitEffect(ExportReportEffect.success('PDF report created successfully'));
    } on DioException {
      emit(state.copyWith(isExporting: false));
      emitEffect(ExportReportEffect.error('Network error while fetching time entries. Please check your connection.'));
    } on FileSystemException {
      emit(state.copyWith(isExporting: false));
      emitEffect(ExportReportEffect.error('Failed to save PDF file. Please check storage permissions.'));
    } catch (e) {
      emit(state.copyWith(isExporting: false));
      emitEffect(ExportReportEffect.error('Failed to export PDF report. Please try again.'));
    }
  }

  pw.Widget _buildPdfCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.white : PdfColors.black,
        ),
      ),
    );
  }
}
