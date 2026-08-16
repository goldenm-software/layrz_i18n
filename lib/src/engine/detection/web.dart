import 'package:flutter/widgets.dart';
import 'package:layrz_i18n/src/utils/locale_parser.dart';
import 'package:web/web.dart';

/// Detects the system locale on web platforms.
///
/// Returns the browser locale by parsing [window.navigator.language] using [parseLocale].
/// This function is used on web platforms when compiled to JavaScript.
///
/// Returns:
/// A [Locale] representing the browser's system locale.
Locale getLanguage() => parseLocale(window.navigator.language);
