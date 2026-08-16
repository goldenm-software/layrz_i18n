import 'package:flutter/widgets.dart';

import 'localizations.dart';

/// Convenience extension for accessing [LayrzI18n] from a [BuildContext].
///
/// Provides ergonomic alternatives to [LayrzI18n.of] and
/// [LayrzI18n.maybeOf], allowing you to write `context.i18n.t('key')`
/// instead of `LayrzI18n.of(context).t('key')`.
///
/// Example:
/// ```dart
/// Text(context.i18n.t('greeting', {'name': 'Alice'}))
/// ```
extension LayrzI18nContextExtension on BuildContext {
  /// Gets the [LayrzI18n] instance from the nearest ancestor.
  ///
  /// Asserts if [LayrzI18n] is not in the widget tree. If you need
  /// a nullable variant that returns `null` instead of throwing, use [maybeI18n].
  ///
  /// Throws [FlutterError] if [LayrzI18n] is not available in the tree.
  LayrzI18n get i18n => LayrzI18n.of(this);

  /// Gets the [LayrzI18n] instance from the nearest ancestor, or `null`.
  ///
  /// Returns `null` if [LayrzI18n] is not in the widget tree.
  /// Use this when you are not certain that [LayrzI18n] is available.
  LayrzI18n? get maybeI18n => LayrzI18n.maybeOf(this);
}
