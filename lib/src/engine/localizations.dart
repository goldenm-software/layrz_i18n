import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:layrz_i18n/src/models/available_language.dart';

import 'delegate.dart';
import 'locale_resolver.dart';
import 'template.dart';

/// Main localizations class providing translation and rich text rendering methods.
///
/// Provides methods to translate keys with and without pluralization, with plain
/// arguments and rich text arguments. Supports developer mode for debugging.
class LayrzI18n {
  /// Creates a new [LayrzI18n] instance.
  ///
  /// Arguments:
  /// [languages] is the list of available languages
  /// [currentLocale] is the locale to use (defaults to detected locale)
  /// [fallbackLocale] is the locale to fall back to if current is not found
  LayrzI18n({required this.languages, Locale? currentLocale, this.fallbackLocale = const Locale('en')})
    : locale = currentLocale ?? detectedLocale;

  /// The list of available languages.
  final List<AvailableLanguage?> languages;

  /// The current locale.
  final Locale locale;

  /// The fallback locale.
  final Locale fallbackLocale;

  /// Static flag for developer mode.
  static bool _developerMode = false;

  /// Cached translations for the current locale.
  late Map<String, String> _messages;

  /// Cached fallback translations.
  late Map<String, String> _fallback;

  /// Default translations for missing keys.
  static const Map<String, String> _defaultTranslations = {
    'helpers.error.disaster': 'We are sorry, but something went wrong',
    'errors.not_found': 'We are sorry, but the object you are looking for does not exist',
  };

  /// Gets the detected system locale.
  static Locale get detectedLocale => resolveDetectedLocale();

  /// Gets the current developer mode state.
  bool get developerMode => LayrzI18n._developerMode;

  /// Sets the global developer mode state.
  ///
  /// Arguments:
  /// [value] is the new developer mode state
  static void setDeveloperMode(bool value) {
    LayrzI18n._developerMode = value;
  }

  /// Gets the instance of [LayrzI18n] for the given context.
  ///
  /// This will assert if [LayrzI18n] is not found.
  ///
  /// Arguments:
  /// [context] is the build context
  ///
  /// Returns:
  /// The [LayrzI18n] instance.
  static LayrzI18n of(BuildContext context) {
    assert(debugCheckHasLayrzI18n(context));
    return Localizations.of<LayrzI18n>(context, LayrzI18n)!;
  }

  /// Gets the instance of [LayrzI18n] for the given context.
  ///
  /// Returns null if [LayrzI18n] is not found.
  ///
  /// Arguments:
  /// [context] is the build context
  ///
  /// Returns:
  /// The [LayrzI18n] instance, or null.
  static LayrzI18n? maybeOf(BuildContext context) {
    return Localizations.of<LayrzI18n>(context, LayrzI18n);
  }

  /// Loads translations for the current locale.
  ///
  /// Builds a locale-keyed index from all languages and sets up [_messages]
  /// and [_fallback] maps for fast lookup.
  Future<bool> load() async {
    final index = <Locale, AvailableLanguage>{};
    for (final lang in languages) {
      if (lang != null) {
        index[lang.getLocale()] = lang;
      }
    }
    _messages = index[locale]?.messages ?? const {};
    _fallback = index[fallbackLocale]?.messages ?? const {};
    return true;
  }

  /// Checks if a translation exists for the given key.
  ///
  /// Arguments:
  /// [key] is the translation key
  ///
  /// Returns:
  /// True if a translation exists in the current locale.
  bool hasTranslation(String key) {
    return _messages.containsKey(key);
  }

  /// Gets the closest matching locale for a given code string.
  ///
  /// Tries to find an exact match, then a language code match in the current
  /// locale, then in the detected locale, and falls back to the fallback locale.
  ///
  /// Arguments:
  /// [prevLanguage] is the previously saved language code
  /// [supportedLocales] is the list of supported locales
  /// [fallbackLocale] is the fallback locale
  ///
  /// Returns:
  /// The closest matching [Locale].
  static Locale getClosestLocale({
    String? prevLanguage,
    required List<Locale> supportedLocales,
    required Locale fallbackLocale,
  }) {
    return getClosestLocaleImpl(
      prevLanguage: prevLanguage,
      supportedLocales: supportedLocales,
      fallbackLocale: fallbackLocale,
    );
  }

  /// Gets the raw message for the given key, falling back through layers.
  String _raw(String key) =>
      _messages[key] ?? _fallback[key] ?? _defaultTranslations[key] ?? 'Translation missing $key';

  /// Translates a string with optional plain text arguments.
  ///
  /// Replaces `{key}` markers with corresponding argument values. If developer
  /// mode is enabled, returns a debug string instead.
  ///
  /// Arguments:
  /// [key] is the translation key
  /// [args] is a map of argument names to values
  ///
  /// Returns:
  /// The translated and interpolated string.
  String t(String key, [Map<String, dynamic> args = const {}]) {
    if (developerMode) {
      return '$key : ${jsonEncode(args)}';
    }

    if (args.isEmpty) {
      return _raw(key);
    }

    final rawMessage = _raw(key);
    final template = getTemplate(rawMessage);
    return template.render(template.tokens, args);
  }

  /// Translates a string with optional pluralization and arguments.
  ///
  /// The translation value should contain two forms separated by ' | '. If [val]
  /// is 1, the first form is used; otherwise the second form is used (or the
  /// first if only one form exists).
  ///
  /// Arguments:
  /// [key] is the translation key
  /// [val] is the count value to determine which plural form to use
  /// [args] is a map of argument names to values
  ///
  /// Returns:
  /// The translated, pluralized, and interpolated string.
  String tc(String key, int? val, [Map<String, dynamic> args = const {}]) {
    if (developerMode) {
      return '$key|$val : ${jsonEncode(args)}';
    }

    final rawMessage = _raw(key);
    final template = getTemplate(rawMessage);

    // Determine which plural form to use
    final formIndex = val == 1 ? 0 : (template.forms.length > 1 ? 1 : 0);
    final form = template.forms[formIndex];

    // Render with the selected form
    return template.render(form, args);
  }

  /// Translates a string with optional arguments and rich text arguments.
  ///
  /// Similar to [t], but returns a [TextSpan] and supports rich text arguments
  /// via the `[key]` marker syntax. Plain text arguments use `{key}` markers.
  ///
  /// If developer mode is enabled, returns a debug [TextSpan].
  ///
  /// Arguments:
  /// [key] is the translation key
  /// [args] is a map of plain argument names to values
  /// [richArgs] is a map of rich argument names to [InlineSpan] values
  /// [style] is an optional base text style for all spans
  ///
  /// Returns:
  /// A [TextSpan] with interpolated values and rich text formatting.
  ///
  /// Example usage:
  /// ```dart
  /// RichText(
  ///   text: TextSpan(
  ///     children: [
  ///       TextSpan(
  ///         text: 'Example -> ',
  ///         style: TextStyle(fontSize: 16),
  ///       ),
  ///       i18n.te(
  ///         'my.awesome.translation.key', // Will translate to "Hello [text]"
  ///         richArgs: {
  ///           'text': WidgetSpan(
  ///             alignment: PlaceholderAlignment.middle,
  ///             child: GestureDetector(
  ///               onTap: () => debugPrint('Hello World'),
  ///               child: Text(
  ///                 'World',
  ///                 style: TextStyle(
  ///                   color: const Color(0xFF00FF00),
  ///                   decoration: TextDecoration.underline,
  ///                 ),
  ///               ),
  ///             ),
  ///           ),
  ///         },
  ///         style: TextStyle(fontSize: 16),
  ///       ),
  ///     ],
  ///   ),
  /// );
  /// ```
  TextSpan te(
    String key, {
    Map<String, dynamic> args = const {},
    Map<String, InlineSpan> richArgs = const {},
    TextStyle? style,
  }) {
    if (developerMode) {
      return TextSpan(text: '$key : args: ${jsonEncode(args)} | richArgs.keys: ${richArgs.keys}', style: style);
    }

    if (args.isEmpty && richArgs.isEmpty) {
      return TextSpan(text: _raw(key), style: style);
    }

    final rawMessage = _raw(key);
    final template = getTemplate(rawMessage);
    return template.renderRich(template.tokens, args, richArgs, style);
  }

  /// Translates a string with optional pluralization, arguments, and rich text.
  ///
  /// Combines [tc] and [te] functionality. The translation value should contain
  /// two forms separated by ' | '. Uses the form selection logic from [tc] and
  /// the rich text rendering from [te].
  ///
  /// Arguments:
  /// [key] is the translation key
  /// [val] is the count value to determine which plural form to use
  /// [args] is a map of plain argument names to values
  /// [richArgs] is a map of rich argument names to [InlineSpan] values
  /// [style] is an optional base text style for all spans
  ///
  /// Returns:
  /// A [TextSpan] with pluralized, interpolated, and rich text-formatted content.
  ///
  /// Example usage:
  /// ```dart
  /// RichText(
  ///   text: TextSpan(
  ///     children: [
  ///       TextSpan(
  ///         text: 'Example -> ',
  ///         style: TextStyle(fontSize: 16),
  ///       ),
  ///       i18n.tce(
  ///         'my.awesome.translation.key',
  ///         5,
  ///         richArgs: {
  ///           'text': WidgetSpan(
  ///             alignment: PlaceholderAlignment.middle,
  ///             child: GestureDetector(
  ///               onTap: () => debugPrint('Hello World'),
  ///               child: Text(
  ///                 'World',
  ///                 style: TextStyle(
  ///                   color: const Color(0xFF00FF00),
  ///                   decoration: TextDecoration.underline,
  ///                 ),
  ///               ),
  ///             ),
  ///           ),
  ///         },
  ///         style: TextStyle(fontSize: 16),
  ///       ),
  ///     ],
  ///   ),
  /// );
  /// ```
  TextSpan tce(
    String key,
    int? val, {
    Map<String, dynamic> args = const {},
    Map<String, InlineSpan> richArgs = const {},
    TextStyle? style,
  }) {
    if (developerMode) {
      return TextSpan(text: '$key | $val : args: ${jsonEncode(args)} | richArgs.keys: ${richArgs.keys}', style: style);
    }

    final rawMessage = _raw(key);
    final template = getTemplate(rawMessage);

    // Determine which plural form to use
    final formIndex = val == 1 ? 0 : (template.forms.length > 1 ? 1 : 0);
    final form = template.forms[formIndex];

    // Render with the selected form
    return template.renderRich(form, args, richArgs, style);
  }

  /// Deprecated: Use [t] instead.
  @Deprecated('`translate()` was deprecated in favor of `t()`. Please use `t()` instead.')
  String translate(String key, [Map<String, dynamic> args = const {}]) => t(key, args);

  /// Gets the [LocalizationsDelegate] for this library.
  ///
  /// Arguments:
  /// [languages] is the list of available languages
  /// [supportedLocales] is the list of supported locales
  /// [fallbackLocale] is the locale to use as a fallback
  ///
  /// Returns:
  /// A [LocalizationsDelegate] for wiring into MaterialApp or WidgetsApp.
  static LocalizationsDelegate<LayrzI18n> delegate({
    required List<AvailableLanguage?> languages,
    required List<Locale> supportedLocales,
    Locale fallbackLocale = const Locale('en'),
  }) {
    return LayrzI18nDelegate(
      languages: languages,
      supportedLocales: supportedLocales,
      fallbackLocale: fallbackLocale,
    );
  }
}
