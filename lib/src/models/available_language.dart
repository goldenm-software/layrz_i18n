import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:layrz_i18n/src/utils/locale_parser.dart';

import 'saved_language.dart';

part 'available_language.freezed.dart';
part 'available_language.g.dart';

/// A language available in the system.
///
/// Represents a language with translations and metadata, including
/// language ID, display name, language code, fallback language, and messages.
///
/// Note: Uses `@Freezed(makeCollectionsUnmodifiable: false)` to avoid wrapping
/// the [messages] map in [EqualUnmodifiableMapView] on every accessor call.
/// The default `makeCollectionsUnmodifiable: true` would add a wrapper indirection
/// on the hottest path in the package ([LayrzAppLocalizations.load()] and [_raw()]),
/// creating allocations on every widget build. The [messages] map is returned
/// as-is; callers must not mutate it.
@Freezed(makeCollectionsUnmodifiable: false)
abstract class AvailableLanguage with _$AvailableLanguage {
  AvailableLanguage._();

  /// Creates a new [AvailableLanguage].
  factory AvailableLanguage({
    /// The unique identifier of the language.
    String? id,

    /// The display name of the language in its native language.
    ///
    /// Example: "English", "Français", "Español"
    String? name,

    /// The language code (e.g., "en", "fr", "es-ES").
    String? code,

    /// The fallback language code if this language is not available.
    String? fallback,

    /// A map of translation keys to translated message strings.
    ///
    /// The map is returned as-is and must not be mutated by callers.
    Map<String, String>? messages,
  }) = _AvailableLanguage;

  /// Returns the [Locale] for this language.
  ///
  /// Parses the [code] field to extract language and region components.
  ///
  /// Returns:
  /// A [Locale] constructed from the language code.
  Locale getLocale() => parseLocale(code);

  /// Converts this to a [SavedLanguage].
  ///
  /// Returns:
  /// A [SavedLanguage] with the ID, name, and code of this language.
  SavedLanguage toSavedLanguage() {
    return SavedLanguage(id: id, name: name, code: code);
  }

  /// Constructs an [AvailableLanguage] from JSON.
  factory AvailableLanguage.fromJson(Map<String, dynamic> json) => _$AvailableLanguageFromJson(json);
}
