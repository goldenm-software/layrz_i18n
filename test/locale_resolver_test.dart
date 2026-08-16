import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:layrz_i18n/src/engine/locale_resolver.dart';

void main() {
  group('locale_resolver', () {
    test('resolveDetectedLocale() returns a Locale', () {
      final detected = resolveDetectedLocale();
      expect(detected, isA<Locale>());
    });

    test('getClosestLocaleImpl() returns exact match when prevLanguage matches', () {
      final supportedLocales = [
        const Locale('en'),
        const Locale('fr'),
      ];

      final result = getClosestLocaleImpl(
        prevLanguage: 'en',
        supportedLocales: supportedLocales,
        fallbackLocale: const Locale('en'),
      );

      expect(result.languageCode, equals('en'));
    });

    test('getClosestLocaleImpl() returns language-code match when exact match fails', () {
      final supportedLocales = [
        const Locale('en', 'US'),
        const Locale('fr'),
      ];

      final result = getClosestLocaleImpl(
        prevLanguage: 'en',
        supportedLocales: supportedLocales,
        fallbackLocale: const Locale('en'),
      );

      expect(result.languageCode, equals('en'));
    });

    test('getClosestLocaleImpl() returns detected locale exact match', () {
      final supportedLocales = [
        const Locale('en'),
        const Locale('fr'),
      ];

      final result = getClosestLocaleImpl(
        prevLanguage: null,
        supportedLocales: supportedLocales,
        fallbackLocale: const Locale('en'),
      );

      // Result should be either detected locale or fallback
      expect(supportedLocales, contains(result));
    });

    test('getClosestLocaleImpl() returns detected language-code match', () {
      final supportedLocales = [
        const Locale('en', 'US'),
        const Locale('fr'),
      ];

      final result = getClosestLocaleImpl(
        prevLanguage: null,
        supportedLocales: supportedLocales,
        fallbackLocale: const Locale('en'),
      );

      // Result should have a language code that matches one in supported
      expect(
        supportedLocales.map((l) => l.languageCode),
        contains(result.languageCode),
      );
    });

    test('getClosestLocaleImpl() falls back to fallbackLocale when nothing matches', () {
      final supportedLocales = [
        const Locale('fr'),
        const Locale('de'),
      ];

      final result = getClosestLocaleImpl(
        prevLanguage: 'xx', // Non-existent language
        supportedLocales: supportedLocales,
        fallbackLocale: const Locale('en'),
      );

      // Should fall back to the fallback locale
      expect(result, equals(const Locale('en')));
    });

    test('getClosestLocaleImpl() returns fallbackLocale when supportedLocales is empty', () {
      final result = getClosestLocaleImpl(
        prevLanguage: 'en',
        supportedLocales: const [],
        fallbackLocale: const Locale('en'),
      );

      expect(result, equals(const Locale('en')));
    });

    test('getClosestLocaleImpl() with null prevLanguage falls through to detected locale', () {
      final supportedLocales = [
        const Locale('en'),
        const Locale('fr'),
      ];

      final result = getClosestLocaleImpl(
        prevLanguage: null,
        supportedLocales: supportedLocales,
        fallbackLocale: const Locale('en'),
      );

      // Should successfully resolve (no exception)
      expect(result, isA<Locale>());
    });
  });
}
