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

  // Track initialization state to prevent showing consent dialog if init failed
  bool _isInitialized = false;

  /// Initialize Countly and schedule consent prompt if needed.
  /// This will read stored consent from SettingsRepository and enable
  /// consent at init if already granted. If consent is not set, it will
  /// initialize Countly with requiresConsent=true (no consents) and then
  /// show the consent dialog after ~2 seconds.
  Future<void> initialize() async {
    try {
      final appKey = EnvVars.get('COUNTLY_APP_KEY');
      final serverUrl = EnvVars.get('COUNTLY_URL');

      if (appKey == null || serverUrl == null) {
        print('Countly app key or server URL is missing - analytics disabled');
        return;
      }

      final consentGiven = await _settingsRepository.analyticsConsent;

      final config = CountlyConfig(serverUrl, appKey)
        ..setLoggingEnabled(true)
        ..enableCrashReporting()
        ..setRequiresConsent(true);

      if (consentGiven == true) {
        config.setConsentEnabled(requiredConsents);
      }

      // Initialize with timeout to prevent hanging if server unreachable
      final result = await Countly.initWithConfig(config).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print(
            'Countly initialization timed out - continuing without analytics',
          );
          return null; // Indicates timeout
        },
      );

      // Only mark as initialized if it actually succeeded (didn't timeout)
      if (result != null) {
        _isInitialized = true;
      } else {
        print('Countly not initialized - analytics disabled');
        return; // Exit early, don't schedule consent dialog
      }

      // If consent hasn't been asked yet, schedule it after first frame is rendered
      // This ensures the widget tree is fully built, context is available,
      // and Countly is fully initialized
      if (consentGiven == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Add small delay to ensure user sees the app first
          Future.delayed(const Duration(seconds: 2), () {
            // Double-check initialization succeeded before showing dialog
            if (_isInitialized) {
              _askForConsent();
            }
          });
        });
      }
      if (!_isInitialized) {
        print('Cannot give consent - Countly not initialized');
        return;
      }
    } catch (e, stackTrace) {
      // Never let analytics crash the app
      print('Analytics initialization failed: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> giveConsent() async {
    await Countly.giveConsent(requiredConsents);
  }

  Future<void> _askForConsent() async {
    try {
      final navigatorState = navigatorKey.currentState;
      if (navigatorState == null || !navigatorState.mounted) {
        print('Analytics consent dialog skipped: Navigator not available');
        return;
      }

      final context = navigatorState.context;

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
