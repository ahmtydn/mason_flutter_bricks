import 'package:flutter/material.dart';
import 'package:{{project_name.snakeCase()}}/product/l10n/gen/app_localizations.dart';

/// Global localization service for accessing translations without context
class AppLocalizationService {
  static AppLocalizations? _localizations;
  static Locale _currentLocale = const Locale('en');

  /// Initialize the service with app localizations
  static void initialize(AppLocalizations localizations, Locale locale) {
    _localizations = localizations;
    _currentLocale = locale;
  }

  /// Get current localizations instance
  static AppLocalizations get current {
    if (_localizations == null) {
      throw Exception(
        'AppLocalizationService not initialized. '
        'Call initialize() first.',
      );
    }
    return _localizations!;
  }

  /// Get current locale
  static Locale get currentLocale => _currentLocale;

  /// Check if service is initialized
  static bool get isInitialized => _localizations != null;
}
