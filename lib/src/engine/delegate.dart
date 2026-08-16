import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../models/available_language.dart';
import 'localizations.dart';

/// A [LocalizationsDelegate] for [LayrzAppLocalizations].
///
/// Provides localization support for a Flutter app by loading translations
/// based on the current locale and specified supported locales.
class LayrzAppLocalizationsDelegate extends LocalizationsDelegate<LayrzAppLocalizations> {
  /// Creates a new [LayrzAppLocalizationsDelegate].
  ///
  /// Arguments:
  /// [languages] is the list of available languages
  /// [supportedLocales] is the list of supported locales
  /// [fallbackLocale] is the locale to fall back to if no match is found
  LayrzAppLocalizationsDelegate({
    required this.languages,
    required this.supportedLocales,
    required this.fallbackLocale,
  });

  /// The list of available languages.
  final List<AvailableLanguage?> languages;

  /// The list of supported locales.
  final List<Locale> supportedLocales;

  /// The fallback locale.
  final Locale fallbackLocale;

  /// The current locale.
  Locale? currentLocale;

  @override
  bool isSupported(Locale locale) {
    return supportedLocales.contains(locale);
  }

  @override
  Future<LayrzAppLocalizations> load(Locale locale) async {
    currentLocale = locale;
    final localizations = LayrzAppLocalizations(
      languages: languages,
      currentLocale: locale,
      fallbackLocale: fallbackLocale,
    );
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(LayrzAppLocalizationsDelegate old) =>
      !listEquals(languages, old.languages) ||
      !listEquals(supportedLocales, old.supportedLocales) ||
      fallbackLocale != old.fallbackLocale;
}

/// Checks that [LayrzAppLocalizations] is available in the given context.
///
/// This is a debug assertion that throws a [FlutterError] if
/// [LayrzAppLocalizations] is not found. Always returns true in release builds.
///
/// Arguments:
/// [context] is the build context to check
///
/// Returns:
/// True if [LayrzAppLocalizations] is available or in release mode.
bool debugCheckHasLayrzAppLocalizations(BuildContext context) {
  assert(() {
    if (Localizations.of<LayrzAppLocalizations>(context, LayrzAppLocalizations) == null) {
      throw FlutterError('LayrzAppLocalizations was used before it was initialized');
    }
    return true;
  }());
  return true;
}
