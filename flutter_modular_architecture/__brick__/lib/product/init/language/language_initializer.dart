import 'package:flutter/material.dart';
import 'package:{{project_name.snakeCase()}}/l10n/gen/app_localizations.dart';

class LanguageInitializer {
  const LanguageInitializer._();

  static Iterable<LocalizationsDelegate<dynamic>> get delegates {
    return AppLocalizations.localizationsDelegates;
  }

  static List<Locale> get supportedLocales {
    return AppLocalizations.supportedLocales;
  }

  static Locale get fallbackLocale => const Locale('en');
}
