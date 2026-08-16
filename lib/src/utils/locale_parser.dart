import 'package:flutter/widgets.dart';

/// Parses a locale string into a [Locale].
///
/// Handles various formats:
/// - `null` or `''` returns `Locale('en')`
/// - `'en'` returns `Locale('en')`
/// - `'en-US'` and `'en_US'` return `Locale('en','US')`
/// - `'en-'` and `'en_'` return `Locale('en')` (fixes malformed codes)
/// - `'zh-Hans-CN'` returns `Locale('zh','Hans')` (preserves second segment as region)
///
/// Arguments:
/// [code] is the raw locale code string to parse
///
/// Returns:
/// A properly constructed [Locale] with language and optional region codes.
Locale parseLocale(String? code) {
  if (code == null || code.isEmpty) {
    return const Locale('en');
  }

  // Normalize underscore to hyphen
  final normalized = code.replaceAll('_', '-');

  // Split on hyphen
  final parts = normalized.split('-');

  // Extract language (first part)
  final language = parts[0];

  // Extract region (second part, only if non-empty)
  if (parts.length > 1 && parts[1].isNotEmpty) {
    return Locale(language, parts[1]);
  }

  // Language only (or second part was empty)
  return Locale(language);
}
