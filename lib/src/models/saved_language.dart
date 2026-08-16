import 'package:flutter/widgets.dart';

import 'package:layrz_i18n/src/utils/locale_parser.dart';

/// A language reference without translation data.
///
/// Represents a language with basic metadata but without the full translation
/// map. Useful for storing user language preferences.
class SavedLanguage {
  /// Creates a new [SavedLanguage].
  ///
  /// Arguments:
  /// [id] is the unique identifier of the language
  /// [name] is the display name of the language
  /// [code] is the language code
  SavedLanguage({required this.id, required this.name, required this.code});

  /// The unique identifier of the language.
  final String? id;

  /// The display name of the language.
  final String? name;

  /// The language code.
  final String? code;

  /// Returns the [Locale] for this language.
  ///
  /// Parses the [code] field to extract language and region components.
  ///
  /// Returns:
  /// A [Locale] constructed from the language code.
  Locale getLocale() => parseLocale(code);

  @override
  String toString() {
    return 'SavedLanguage{id: $id, code: $code, name: $name}';
  }
}
