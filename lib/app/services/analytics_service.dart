import 'dart:async';

import 'package:countly_flutter/countly_flutter.dart';
import 'package:open_project_time_tracker/app/storage/env_vars.dart';
import 'package:open_project_time_tracker/app/di/inject.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/settings_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/l10n/app_localizations.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_project_time_tracker/main.dart' show navigatorKey;

class AnalyticsService {
  static const requiredConsents = [
    CountlyConsent.crashes,
    CountlyConsent.sessions,
    CountlyConsent.apm,
    CountlyConsent.location,
    CountlyConsent.events,
  ];

  final SettingsRepository _settingsRepository = inject();

  /// Initialize Countly and schedule consent prompt if needed.
  /// This will read stored consent from SettingsRepository and enable
  /// consent at init if already granted. If consent is not set, it will
  /// initialize Countly with requiresConsent=true (no consents) and then
  /// show the consent dialog after ~2 seconds.
  Future<void> initialize() async {
    final appKey = EnvVars.get('COUNTLY_APP_KEY');
    final serverUrl = EnvVars.get('COUNTLY_URL');

    bool? consentGiven = await _settingsRepository.analyticsConsent;

    if (appKey != null && serverUrl != null) {
      CountlyConfig config = CountlyConfig(serverUrl, appKey);
      config.setLoggingEnabled(true);
      config.enableCrashReporting();
      config.setRequiresConsent(true);
      if (consentGiven == true) {
        config.setConsentEnabled(requiredConsents);
      }

      Countly.initWithConfig(config);

      // If consent hasn't been asked yet, ask after 2s without blocking init.
      if (consentGiven == null) {
        Future.delayed(const Duration(seconds: 2), () => _askForConsent());
      }
    } else {
      print('Countly app key or server URL is missing');
    }
  }

  Future<void> giveConsent() async {
    Countly.giveConsent(requiredConsents);
  }

  Future<void> _askForConsent() async {
    try {
      final context = navigatorKey.currentState!.context;

      await showCupertinoDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(
              AppLocalizations.of(context).analytics_consent_request__title,
            ),
            content: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: AppLocalizations.of(
                  context,
                ).analytics_consent_request__text,
                style: const TextStyle(fontSize: 14.0, color: Colors.black),
                children: [
                  TextSpan(
                    text:
                        '\n${AppLocalizations.of(context).analytics_consent_request__privacy_policy}',
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        final url = Uri.parse(
                          EnvVars.get('PRIVACY_POLICY_URL') ?? '',
                        );
                        if (url.toString().isNotEmpty) {
                          if (!await launchUrl(url)) {
                            // ignore
                          }
                        }
                      },
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () async {
                  await _settingsRepository.setAnalyticsConsent(false);
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizations.of(context).generic_decline),
              ),
              CupertinoDialogAction(
                onPressed: () async {
                  await _settingsRepository.setAnalyticsConsent(true);
                  await giveConsent();
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizations.of(context).generic_accept),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Analytics consent flow failed: $e');
    }
  }
}
