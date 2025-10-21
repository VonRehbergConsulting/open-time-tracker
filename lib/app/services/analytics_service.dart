import 'package:countly_flutter/countly_flutter.dart';
import 'package:open_project_time_tracker/app/storage/env_vars.dart';

class AnalyticsService {
  static const requiredConsents = [
    CountlyConsent.crashes,
    CountlyConsent.sessions,
    CountlyConsent.apm,
    CountlyConsent.location,
  ];

  Future<void> initialize({bool consentGiven = false}) async {
    final appKey = EnvVars.get('COUNTLY_APP_KEY');
    final serverUrl = EnvVars.get('COUNTLY_URL');
    if (appKey != null && serverUrl != null) {
      CountlyConfig config = CountlyConfig(serverUrl, appKey);
      config.setLoggingEnabled(true);
      config.enableCrashReporting();
      config.setRequiresConsent(true);
      if (consentGiven) {
        config.setConsentEnabled(requiredConsents);
      }

      Countly.initWithConfig(config);
    } else {
      print('Countly app key or server URL is missing');
    }
  }

  Future<void> giveConsent() async {
    Countly.giveConsent(requiredConsents);
  }
}
