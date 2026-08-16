import 'dart:io';

import 'package:flutter/widgets.dart';

import 'package:layrz_i18n/src/utils/locale_parser.dart';

/// Detects the system locale on native platforms.
///
/// Returns the system locale by parsing [Platform.localeName] using [parseLocale].
/// This function is used on Android, iOS, macOS, Windows, and Linux platforms.
///
/// Returns:
/// A [Locale] representing the platform's system locale.
Locale getLanguage() => parseLocale(Platform.localeName);
