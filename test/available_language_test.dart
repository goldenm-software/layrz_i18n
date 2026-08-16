import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:layrz_i18n/layrz_i18n.dart';

void main() {
  group('AvailableLanguage', () {
    test('fromJson() deserializes correctly', () {
      final json = {
        'id': '1',
        'name': 'English',
        'code': 'en',
        'fallback': 'en',
        'messages': {
          'key1': 'value1',
          'key2': 'value2',
        },
      };

      final lang = AvailableLanguage.fromJson(json);

      expect(lang.id, equals('1'));
      expect(lang.name, equals('English'));
      expect(lang.code, equals('en'));
      expect(lang.fallback, equals('en'));
      expect(lang.messages, equals({'key1': 'value1', 'key2': 'value2'}));
    });

    test('toJson() serializes correctly', () {
      final lang = AvailableLanguage(
        id: '1',
        name: 'English',
        code: 'en',
        fallback: 'en',
        messages: {
          'key1': 'value1',
        },
      );

      final json = lang.toJson();

      expect(json['id'], equals('1'));
      expect(json['name'], equals('English'));
      expect(json['code'], equals('en'));
      expect(json['fallback'], equals('en'));
      expect(json['messages'], equals({'key1': 'value1'}));
    });

    test('fromJson()/toJson() round-trip preserves all fields', () {
      final original = AvailableLanguage(
        id: '42',
        name: 'Français',
        code: 'fr-FR',
        fallback: 'en',
        messages: {
          'greeting': 'Bonjour',
          'farewell': 'Au revoir',
        },
      );

      final json = original.toJson();
      final restored = AvailableLanguage.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.name, equals(original.name));
      expect(restored.code, equals(original.code));
      expect(restored.fallback, equals(original.fallback));
      expect(restored.messages, equals(original.messages));
    });

    test('fromJson() handles null fields', () {
      final json = {
        'id': null,
        'name': null,
        'code': 'en',
        'fallback': null,
        'messages': null,
      };

      final lang = AvailableLanguage.fromJson(json);

      expect(lang.id, isNull);
      expect(lang.name, isNull);
      expect(lang.code, equals('en'));
      expect(lang.fallback, isNull);
      expect(lang.messages, isNull);
    });

    test('fromJson()/toJson() round-trip with null fields', () {
      final original = AvailableLanguage(
        id: null,
        name: null,
        code: 'en',
        fallback: null,
        messages: null,
      );

      final json = original.toJson();
      final restored = AvailableLanguage.fromJson(json);

      expect(restored.id, isNull);
      expect(restored.name, isNull);
      expect(restored.code, equals('en'));
      expect(restored.fallback, isNull);
      expect(restored.messages, isNull);
    });

    test('getLocale() parses simple language code', () {
      final lang = AvailableLanguage(
        id: '1',
        code: 'en',
        name: 'English',
        messages: const {},
      );

      final locale = lang.getLocale();
      expect(locale, equals(const Locale('en')));
    });

    test('getLocale() parses language and region code', () {
      final lang = AvailableLanguage(
        id: '1',
        code: 'en-US',
        name: 'English (US)',
        messages: const {},
      );

      final locale = lang.getLocale();
      expect(locale, equals(const Locale('en', 'US')));
    });

    test('getLocale() parses three-part code preserving second segment', () {
      final lang = AvailableLanguage(
        id: '1',
        code: 'zh-Hans-CN',
        name: 'Chinese (Simplified)',
        messages: const {},
      );

      final locale = lang.getLocale();
      expect(locale, equals(const Locale('zh', 'Hans')));
    });

    test('getLocale() handles null code', () {
      final lang = AvailableLanguage(
        id: '1',
        code: null,
        name: 'Unknown',
        messages: const {},
      );

      final locale = lang.getLocale();
      expect(locale, equals(const Locale('en')));
    });

    test('toSavedLanguage() creates SavedLanguage with same id, name, code', () {
      final lang = AvailableLanguage(
        id: '42',
        name: 'English',
        code: 'en',
        fallback: 'en',
        messages: {'key': 'value'},
      );

      final saved = lang.toSavedLanguage();

      expect(saved.id, equals('42'));
      expect(saved.name, equals('English'));
      expect(saved.code, equals('en'));
    });

    test('toSavedLanguage() does not include messages', () {
      final lang = AvailableLanguage(
        id: '42',
        name: 'English',
        code: 'en',
        messages: {'key': 'value'},
      );

      final saved = lang.toSavedLanguage();

      // SavedLanguage should not have a messages field
      expect(saved, isA<SavedLanguage>());
    });
  });

  group('SavedLanguage', () {
    test('constructor initializes all fields', () {
      final saved = SavedLanguage(id: '1', name: 'English', code: 'en');

      expect(saved.id, equals('1'));
      expect(saved.name, equals('English'));
      expect(saved.code, equals('en'));
    });

    test('getLocale() parses simple language code', () {
      final saved = SavedLanguage(id: '1', name: 'English', code: 'en');
      final locale = saved.getLocale();

      expect(locale, equals(const Locale('en')));
    });

    test('getLocale() parses language and region code', () {
      final saved = SavedLanguage(id: '1', name: 'English (US)', code: 'en-US');
      final locale = saved.getLocale();

      expect(locale, equals(const Locale('en', 'US')));
    });

    test('getLocale() handles null code', () {
      final saved = SavedLanguage(id: '1', name: 'Unknown', code: null);
      final locale = saved.getLocale();

      expect(locale, equals(const Locale('en')));
    });

    test('toString() returns formatted string', () {
      final saved = SavedLanguage(id: '42', name: 'English', code: 'en');
      final str = saved.toString();

      expect(str, contains('SavedLanguage'));
      expect(str, contains('id: 42'));
      expect(str, contains('code: en'));
      expect(str, contains('name: English'));
    });

    test('toString() with null fields', () {
      final saved = SavedLanguage(id: null, name: null, code: null);
      final str = saved.toString();

      expect(str, contains('SavedLanguage'));
      expect(str, contains('id: null'));
      expect(str, contains('code: null'));
      expect(str, contains('name: null'));
    });
  });
}
