import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:open_project_time_tracker/l10n/app_localizations.dart';

/// Helper class to manage notification permission flow with user-friendly dialogs
class NotificationPermissionHelper {
  static const String _permissionAskedKey = 'notification_permission_asked';

  /// Check if we should proactively ask for notification permission
  /// Returns true if this is the first time asking (on Android 13+)
  static Future<bool> shouldRequestPermission() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;

    // Only relevant for Android 13+ (API 33+)
    // Note: We can't check API level directly in Dart, so we check permission status
    final status = await Permission.notification.status;

    // Skip our dialog only when permission is already granted or can't be requested normally
    if (status.isGranted || status.isPermanentlyDenied) {
      return false;
    }

    // Check if we've asked before
    final prefs = await SharedPreferences.getInstance();
    final hasAskedBefore = prefs.getBool(_permissionAskedKey) ?? false;

    return !hasAskedBefore;
  }

  /// Show explanation dialog and request permission
  /// Returns true if permission was granted
  static Future<bool> requestPermissionWithDialog(BuildContext context) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return true;

    final l10n = AppLocalizations.of(context);

    // Show explanation dialog first
    final shouldAsk = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.permission_notification_title),
        content: Text(l10n.permission_notification_message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.permission_notification_not_now),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.permission_notification_enable),
          ),
        ],
      ),
    );

    // Mark that we've asked
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_permissionAskedKey, true);

    if (shouldAsk != true) {
      return false;
    }

    // Request the actual permission
    final status = await Permission.notification.request();

    // If permanently denied, offer to open settings
    if (status.isPermanentlyDenied) {
      if (!context.mounted) return false;
      await _showOpenSettingsDialog(context);
      return false;
    }

    return status.isGranted;
  }

  /// Ensure notification permission, showing settings dialog if permanently denied
  /// Returns true if permission is granted
  static Future<bool> ensurePermission(BuildContext context) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return true;

    var status = await Permission.notification.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      // Show dialog to open settings
      if (!context.mounted) return false;
      final shouldOpen = await _showOpenSettingsDialog(context);
      if (shouldOpen) {
        await openAppSettings();
      }
      return false;
    }

    // Try to request permission
    status = await Permission.notification.request();

    if (status.isPermanentlyDenied) {
      if (!context.mounted) return false;
      final shouldOpen = await _showOpenSettingsDialog(context);
      if (shouldOpen) {
        await openAppSettings();
      }
      return false;
    }

    return status.isGranted;
  }

  /// Show dialog prompting user to open app settings
  static Future<bool> _showOpenSettingsDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.permission_notification_settings_title),
        content: Text(l10n.permission_notification_settings_message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.generic_no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.permission_notification_open_settings),
          ),
        ],
      ),
    );

    return result == true;
  }

  /// Get error message for denied permission
  static String getDeniedErrorMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return l10n.permission_notification_denied_error;
  }
}
