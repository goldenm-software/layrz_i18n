import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../utils/locale_parser.dart';
import 'detection/native.dart' if (dart.library.js_interop) 'detection/web.dart';

/// Gets the detected system locale.
///
/// Returns the platform's system locale by calling [getLanguage()], which
/// delegates to either native or web implementation based on the target platform.
///
/// Internal implementation detail; not part of the public API.
Locale resolveDetectedLocale() => getLanguage();

/// Gets the closest matching locale for a given code string.
///
/// Tries to find an exact match, then a language code match in the current
/// locale, then in the detected locale, and falls back to the fallback locale.
///
/// Internal implementation detail; not part of the public API.
///
/// Arguments:
/// [prevLanguage] is the previously saved language code
/// [supportedLocales] is the list of supported locales
/// [fallbackLocale] is the fallback locale
///
/// Returns:
/// The closest matching [Locale].
Locale getClosestLocaleImpl({
  String? prevLanguage,
  required List<Locale> supportedLocales,
  required Locale fallbackLocale,
}) {
  if (kDebugMode) {
    debugPrint(
      'layrz_i18n/getClosestLocale(): prevLanguage: $prevLanguage - '
      'supportedLocales: ${supportedLocales.length} - '
      'fallbackLocale: $fallbackLocale',
    );
  }

  Locale? currentLocale;
  Locale? prevLocale;

  if (prevLanguage != null) {
    prevLocale = parseLocale(prevLanguage);
  }

  if (prevLocale != null) {
    currentLocale = supportedLocales.firstWhereOrNull((locale) => locale == prevLocale);
    currentLocale ??= supportedLocales.firstWhereOrNull((locale) {
      return locale.languageCode == prevLocale!.languageCode;
    });
  }

  final detected = resolveDetectedLocale();
  if (kDebugMode) {
    debugPrint('layrz_i18n/getClosestLocale(): detectedLocale: $detected');
  }

  currentLocale ??= supportedLocales.firstWhereOrNull((locale) => locale == detected);
  currentLocale ??= supportedLocales.firstWhereOrNull((locale) {
    return locale.languageCode == detected.languageCode;
  });

  return currentLocale ?? fallbackLocale;
}
