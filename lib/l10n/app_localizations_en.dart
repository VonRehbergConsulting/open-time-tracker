// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get generic_error => 'Something went wrong';

  @override
  String get generic_save => 'Save';

  @override
  String get generic_yes => 'Yes';

  @override
  String get generic_no => 'No';

  @override
  String get generic_warning => 'Warning';

  @override
  String get generic_retry => 'Try again';

  @override
  String get generic_total => 'Total';

  @override
  String get generic_monday_short => 'Mon';

  @override
  String get generic_tuesday_short => 'Tue';

  @override
  String get generic_wednesday_short => 'Wed';

  @override
  String get generic_thursday_short => 'Thu';

  @override
  String get generic_friday_short => 'Fri';

  @override
  String get generic_saturday_short => 'Sat';

  @override
  String get generic_sunday_short => 'Sun';

  @override
  String get generic_deletion_warning =>
      'Your data will be deleted permanently';

  @override
  String get generic__in_progress => 'In progress';

  @override
  String get generic_accept => 'Accept';

  @override
  String get generic_decline => 'Decline';

  @override
  String get generic_today => 'Today';

  @override
  String get generic_yesterday => 'Yesterday';

  @override
  String get authorization_log_in => 'Log in';

  @override
  String get authorization_configure_instance => 'Configure instance';

  @override
  String get instance_configuration_title => 'Instance Configuration';

  @override
  String get instance_configuration_base_url => 'Base URL';

  @override
  String get instance_configuration_client_id => 'Client ID';

  @override
  String get instance_configuration__invalid_url => 'URL is invalid';

  @override
  String get time_entries_list_title => 'Time Recordings';

  @override
  String get time_entries_list_change_working_hours => 'Change working hours';

  @override
  String get time_entries_list_empty => 'No work logged today';

  @override
  String get work_package_list_empty => 'No tasks';

  @override
  String get work_packages_filter__title => 'Filters';

  @override
  String get analytics_title => 'Analytics';

  @override
  String get analytics_empty => 'No time logged this week';

  @override
  String get analytics_weekdays_title => 'Weekdays distribution';

  @override
  String get analytics_projects_title => 'Projects distribution';

  @override
  String get time_entry_summary_title => 'Summary';

  @override
  String get time_entry_summary_task => 'Task';

  @override
  String get time_entry_summary_project => 'Project';

  @override
  String get time_entry_summary_time_spent => 'Time spent';

  @override
  String get time_entry_summary_comment => 'Comment';

  @override
  String get timer_warning =>
      'Your current changes will not be saved. Continue?';

  @override
  String get timer_start => 'Start';

  @override
  String get timer_pause => 'Pause';

  @override
  String get timer_resume => 'Resume';

  @override
  String get timer_finish => 'Finish';

  @override
  String get timer_add_5_min => '+5 min';

  @override
  String get timer_add_15_min => '+15 min';

  @override
  String get timer_add_30_min => '+30 min';

  @override
  String get comment_suggestions_title => 'Choose a comment';

  @override
  String get profile_title => 'Profile';

  @override
  String get profile_subtitle => 'Manage your account';

  @override
  String get profile_calendar_connected => 'Connected';

  @override
  String get profile_calendar_disconnected => 'Not connected';

  @override
  String get profile_logout_title => 'Sign out';

  @override
  String get profile_logout_description => 'Sign out of your account';

  @override
  String get profile_logout_button => 'Sign out';

  @override
  String get calendar_title => 'Calendar notifications';

  @override
  String get calendar_connect => 'Connect calendar';

  @override
  String get calendar_disconnect => 'Disconnect calendar';

  @override
  String get notifications_calendar_title => 'Meeting is starting';

  @override
  String get notifications_calendar_body => 'Open to start a timer';

  @override
  String get notification_selection_list__title => 'Choose task';

  @override
  String get notification_selection_list__time_entries_header => 'Recent work';

  @override
  String get notification_selection_list__work_packages_header =>
      'Active tasks';

  @override
  String get projects_list__title => 'Projects';

  @override
  String get projects_list__updated_at => 'Updated';

  @override
  String get analytics_consent_request__title => 'Share technical data';

  @override
  String get analytics_consent_request__text =>
      'Help us improve app stability and performance by sharing anonymous crash reports and session data. No personal information is collected.';

  @override
  String get analytics_consent_request__privacy_policy => 'Privacy policy';

  @override
  String get monthly_overview_title => 'Monthly Overview';

  @override
  String get monthly_overview_week => 'Week';

  @override
  String get monthly_overview_current_week => 'Current week';

  @override
  String get monthly_overview_weekly => 'Weekly';

  @override
  String get monthly_overview_monthly => 'Monthly';

  @override
  String get monthly_overview_total => 'Total';

  @override
  String get weekday_monday => 'Mon';

  @override
  String get weekday_tuesday => 'Tue';

  @override
  String get weekday_wednesday => 'Wed';

  @override
  String get weekday_thursday => 'Thu';

  @override
  String get weekday_friday => 'Fri';

  @override
  String get weekday_saturday => 'Sat';

  @override
  String get weekday_sunday => 'Sun';

  @override
  String get export_report_title => 'Export Report';

  @override
  String get export_report_date_range => 'Date Range';

  @override
  String get export_report_start_date => 'Start Date';

  @override
  String get export_report_end_date => 'End Date';

  @override
  String get export_report_project_filter => 'Project Filter (Optional)';

  @override
  String get export_report_all_projects => 'All Projects';

  @override
  String get export_report_select_projects => 'Select Projects';

  @override
  String get export_report_add_more_projects => 'Add More Projects';

  @override
  String get export_report_search_projects => 'Search projects...';

  @override
  String get export_report_clear_selection => 'Clear Selection';

  @override
  String get export_report_no_projects => 'No projects available';

  @override
  String get export_report_format => 'Export Format';

  @override
  String get export_report_xlsx => 'Export as Excel (XLSX)';

  @override
  String get export_report_pdf => 'Export as PDF';

  @override
  String get export_report_period => 'Period';

  @override
  String get export_report_column_date => 'Date';

  @override
  String get export_report_column_project => 'Project';

  @override
  String get export_report_column_work_package => 'Work Package';

  @override
  String get export_report_column_hours => 'Hours';

  @override
  String get export_report_column_comment => 'Comment';

  @override
  String get export_report_pdf_summary_by_project => 'Summary by Project';

  @override
  String get export_report_pdf_total_hours => 'Total Hours';

  @override
  String get export_report_excel_open_success =>
      'Excel report opened successfully';

  @override
  String get export_report_excel_open_failed =>
      'Unable to open Excel file. Please check your file viewer settings.';

  @override
  String get export_report_network_fetch_failed =>
      'Network error while fetching time entries. Please check your connection.';

  @override
  String get export_report_excel_save_failed =>
      'Failed to save Excel file. Please check storage permissions.';

  @override
  String get export_report_excel_export_failed =>
      'Failed to export Excel report. Please try again.';

  @override
  String get export_report_pdf_create_success =>
      'PDF report created successfully';

  @override
  String get export_report_pdf_save_failed =>
      'Failed to save PDF file. Please check storage permissions.';

  @override
  String get export_report_pdf_export_failed =>
      'Failed to export PDF report. Please try again.';
}
