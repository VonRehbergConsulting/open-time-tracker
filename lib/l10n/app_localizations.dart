import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @generic_error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get generic_error;

  /// No description provided for @generic_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get generic_save;

  /// No description provided for @generic_yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get generic_yes;

  /// No description provided for @generic_no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get generic_no;

  /// No description provided for @generic_warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get generic_warning;

  /// No description provided for @generic_retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get generic_retry;

  /// No description provided for @generic_total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get generic_total;

  /// No description provided for @generic_monday_short.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get generic_monday_short;

  /// No description provided for @generic_tuesday_short.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get generic_tuesday_short;

  /// No description provided for @generic_wednesday_short.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get generic_wednesday_short;

  /// No description provided for @generic_thursday_short.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get generic_thursday_short;

  /// No description provided for @generic_friday_short.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get generic_friday_short;

  /// No description provided for @generic_saturday_short.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get generic_saturday_short;

  /// No description provided for @generic_sunday_short.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get generic_sunday_short;

  /// No description provided for @generic_deletion_warning.
  ///
  /// In en, this message translates to:
  /// **'Your data will be deleted permanently'**
  String get generic_deletion_warning;

  /// No description provided for @generic__in_progress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get generic__in_progress;

  /// No description provided for @generic_accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get generic_accept;

  /// No description provided for @generic_decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get generic_decline;

  /// No description provided for @authorization_log_in.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get authorization_log_in;

  /// No description provided for @authorization_configure_instance.
  ///
  /// In en, this message translates to:
  /// **'Configure instance'**
  String get authorization_configure_instance;

  /// No description provided for @instance_configuration_title.
  ///
  /// In en, this message translates to:
  /// **'Instance Configuration'**
  String get instance_configuration_title;

  /// No description provided for @instance_configuration_base_url.
  ///
  /// In en, this message translates to:
  /// **'Base URL'**
  String get instance_configuration_base_url;

  /// No description provided for @instance_configuration_client_id.
  ///
  /// In en, this message translates to:
  /// **'Client ID'**
  String get instance_configuration_client_id;

  /// No description provided for @instance_configuration__invalid_url.
  ///
  /// In en, this message translates to:
  /// **'URL is invalid'**
  String get instance_configuration__invalid_url;

  /// No description provided for @time_entries_list_title.
  ///
  /// In en, this message translates to:
  /// **'Recent work'**
  String get time_entries_list_title;

  /// No description provided for @time_entries_list_change_working_hours.
  ///
  /// In en, this message translates to:
  /// **'Change working hours'**
  String get time_entries_list_change_working_hours;

  /// No description provided for @time_entries_list_empty.
  ///
  /// In en, this message translates to:
  /// **'No work logged today'**
  String get time_entries_list_empty;

  /// No description provided for @work_package_list_empty.
  ///
  /// In en, this message translates to:
  /// **'No tasks'**
  String get work_package_list_empty;

  /// No description provided for @work_packages_filter__title.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get work_packages_filter__title;

  /// No description provided for @analytics_title.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics_title;

  /// No description provided for @analytics_empty.
  ///
  /// In en, this message translates to:
  /// **'No time logged this week'**
  String get analytics_empty;

  /// No description provided for @analytics_weekdays_title.
  ///
  /// In en, this message translates to:
  /// **'Weekdays distribution'**
  String get analytics_weekdays_title;

  /// No description provided for @analytics_projects_title.
  ///
  /// In en, this message translates to:
  /// **'Projects distribution'**
  String get analytics_projects_title;

  /// No description provided for @time_entry_summary_title.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get time_entry_summary_title;

  /// No description provided for @time_entry_summary_task.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get time_entry_summary_task;

  /// No description provided for @time_entry_summary_project.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get time_entry_summary_project;

  /// No description provided for @time_entry_summary_time_spent.
  ///
  /// In en, this message translates to:
  /// **'Time spent'**
  String get time_entry_summary_time_spent;

  /// No description provided for @time_entry_summary_comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get time_entry_summary_comment;

  /// No description provided for @timer_warning.
  ///
  /// In en, this message translates to:
  /// **'Your current changes will not be saved. Continue?'**
  String get timer_warning;

  /// No description provided for @timer_start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get timer_start;

  /// No description provided for @timer_pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get timer_pause;

  /// No description provided for @timer_resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get timer_resume;

  /// No description provided for @timer_finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get timer_finish;

  /// No description provided for @timer_add_5_min.
  ///
  /// In en, this message translates to:
  /// **'+5 min'**
  String get timer_add_5_min;

  /// No description provided for @timer_add_15_min.
  ///
  /// In en, this message translates to:
  /// **'+15 min'**
  String get timer_add_15_min;

  /// No description provided for @timer_add_30_min.
  ///
  /// In en, this message translates to:
  /// **'+30 min'**
  String get timer_add_30_min;

  /// No description provided for @comment_suggestions_title.
  ///
  /// In en, this message translates to:
  /// **'Choose a comment'**
  String get comment_suggestions_title;

  /// No description provided for @calendar_title.
  ///
  /// In en, this message translates to:
  /// **'Calendar notifications'**
  String get calendar_title;

  /// No description provided for @calendar_connect.
  ///
  /// In en, this message translates to:
  /// **'Connect calendar'**
  String get calendar_connect;

  /// No description provided for @calendar_disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect calendar'**
  String get calendar_disconnect;

  /// No description provided for @calendar_promo_1.
  ///
  /// In en, this message translates to:
  /// **'Connect your Microsoft calendar to never miss a meeting again'**
  String get calendar_promo_1;

  /// No description provided for @calendar_promo_2.
  ///
  /// In en, this message translates to:
  /// **'Receive timely notifications by connecting your Microsoft calendar, ensuring you always track the right task'**
  String get calendar_promo_2;

  /// No description provided for @calendar_connected_1.
  ///
  /// In en, this message translates to:
  /// **'Your Microsoft calendar is connected'**
  String get calendar_connected_1;

  /// No description provided for @calendar_connected_2.
  ///
  /// In en, this message translates to:
  /// **'You will recieve reminders for your meetings'**
  String get calendar_connected_2;

  /// No description provided for @notifications_calendar_title.
  ///
  /// In en, this message translates to:
  /// **'Meeting is starting'**
  String get notifications_calendar_title;

  /// No description provided for @notifications_calendar_body.
  ///
  /// In en, this message translates to:
  /// **'Open to start a timer'**
  String get notifications_calendar_body;

  /// No description provided for @notification_selection_list__title.
  ///
  /// In en, this message translates to:
  /// **'Choose task'**
  String get notification_selection_list__title;

  /// No description provided for @notification_selection_list__time_entries_header.
  ///
  /// In en, this message translates to:
  /// **'Recent work'**
  String get notification_selection_list__time_entries_header;

  /// No description provided for @notification_selection_list__work_packages_header.
  ///
  /// In en, this message translates to:
  /// **'Active tasks'**
  String get notification_selection_list__work_packages_header;

  /// No description provided for @projects_list__title.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projects_list__title;

  /// No description provided for @projects_list__updated_at.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get projects_list__updated_at;

  /// No description provided for @analytics_consent_request__title.
  ///
  /// In en, this message translates to:
  /// **'Share technical data'**
  String get analytics_consent_request__title;

  /// No description provided for @analytics_consent_request__text.
  ///
  /// In en, this message translates to:
  /// **'Help us improve app stability and performance by sharing anonymous crash reports and session data. No personal information is collected.'**
  String get analytics_consent_request__text;

  /// No description provided for @analytics_consent_request__privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get analytics_consent_request__privacy_policy;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
