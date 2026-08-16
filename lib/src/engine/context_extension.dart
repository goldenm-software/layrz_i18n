import 'package:flutter/widgets.dart';

import 'localizations.dart';

/// Convenience extension for accessing [LayrzAppLocalizations] from a [BuildContext].
///
/// Provides ergonomic alternatives to [LayrzAppLocalizations.of] and
/// [LayrzAppLocalizations.maybeOf], allowing you to write `context.i18n.t('key')`
/// instead of `LayrzAppLocalizations.of(context).t('key')`.
///
/// Example:
/// ```dart
/// Text(context.i18n.t('greeting', {'name': 'Alice'}))
/// ```
extension LayrzI18nContextExtension on BuildContext {
  /// Gets the [LayrzAppLocalizations] instance from the nearest ancestor.
  ///
  /// Asserts if [LayrzAppLocalizations] is not in the widget tree. If you need
  /// a nullable variant that returns `null` instead of throwing, use [maybeI18n].
  ///
  /// Throws [FlutterError] if [LayrzAppLocalizations] is not available in the tree.
  LayrzAppLocalizations get i18n => LayrzAppLocalizations.of(this);

  /// Gets the [LayrzAppLocalizations] instance from the nearest ancestor, or `null`.
  ///
  /// Returns `null` if [LayrzAppLocalizations] is not in the widget tree.
  /// Use this when you are not certain that [LayrzAppLocalizations] is available.
  LayrzAppLocalizations? get maybeI18n => LayrzAppLocalizations.maybeOf(this);
}
