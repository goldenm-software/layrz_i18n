import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:layrz_i18n/layrz_i18n.dart';

void main() {
  group('parseLocale', () {
    test('returns Locale("en") for null', () {
      final result = parseLocale(null);
      expect(result, equals(const Locale('en')));
      expect(result.countryCode, isNull);
    });

    test('returns Locale("en") for empty string', () {
      final result = parseLocale('');
      expect(result, equals(const Locale('en')));
      expect(result.countryCode, isNull);
    });

    test('parses language code only (en)', () {
      final result = parseLocale('en');
      expect(result, equals(const Locale('en')));
      expect(result.languageCode, equals('en'));
      expect(result.countryCode, isNull);
    });

    test('parses language and region with hyphen (en-US)', () {
      final result = parseLocale('en-US');
      expect(result, equals(const Locale('en', 'US')));
      expect(result.languageCode, equals('en'));
      expect(result.countryCode, equals('US'));
    });

    test('parses language and region with underscore (en_US)', () {
      final result = parseLocale('en_US');
      expect(result, equals(const Locale('en', 'US')));
      expect(result.languageCode, equals('en'));
      expect(result.countryCode, equals('US'));
    });

    test('handles malformed locale with trailing hyphen (en-) — countryCode is null', () {
      final result = parseLocale('en-');
      expect(result, equals(const Locale('en')));
      expect(result.languageCode, equals('en'));
      expect(result.countryCode, isNull);
    });

    test('handles malformed locale with trailing underscore (en_) — countryCode is null', () {
      final result = parseLocale('en_');
      expect(result, equals(const Locale('en')));
      expect(result.languageCode, equals('en'));
      expect(result.countryCode, isNull);
    });

    test('parses three-part locale codes preserving second segment as region (zh-Hans-CN)', () {
      final result = parseLocale('zh-Hans-CN');
      expect(result, equals(const Locale('zh', 'Hans')));
      expect(result.languageCode, equals('zh'));
      expect(result.countryCode, equals('Hans'));
    });
  });
}
