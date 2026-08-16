import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../models/available_language.dart';
import 'localizations.dart';

/// A [LocalizationsDelegate] for [LayrzI18n].
///
/// Provides localization support for a Flutter app by loading translations
/// based on the current locale and specified supported locales.
class LayrzI18nDelegate extends LocalizationsDelegate<LayrzI18n> {
  /// Creates a new [LayrzI18nDelegate].
  ///
  /// Arguments:
  /// [languages] is the list of available languages
  /// [supportedLocales] is the list of supported locales
  /// [fallbackLocale] is the locale to fall back to if no match is found
  LayrzI18nDelegate({
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
  Future<LayrzI18n> load(Locale locale) async {
    currentLocale = locale;
    final localizations = LayrzI18n(
      languages: languages,
      currentLocale: locale,
      fallbackLocale: fallbackLocale,
    );
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(LayrzI18nDelegate old) =>
      !listEquals(languages, old.languages) ||
      !listEquals(supportedLocales, old.supportedLocales) ||
      fallbackLocale != old.fallbackLocale;
}

/// Checks that [LayrzI18n] is available in the given context.
///
/// This is a debug assertion that throws a [FlutterError] if
/// [LayrzI18n] is not found. Always returns true in release builds.
///
/// Arguments:
/// [context] is the build context to check
///
/// Returns:
/// True if [LayrzI18n] is available or in release mode.
bool debugCheckHasLayrzI18n(BuildContext context) {
  assert(() {
    if (Localizations.of<LayrzI18n>(context, LayrzI18n) == null) {
      throw FlutterError('LayrzI18n was used before it was initialized');
    }
    return true;
  }());
  return true;
}
