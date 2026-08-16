import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:layrz_i18n/layrz_i18n.dart';

void main() {
  group('LayrzAppLocalizations.t()', () {
    late LayrzAppLocalizations i18n;

    setUp(() {
      final language = AvailableLanguage(
        id: '1',
        code: 'en',
        name: 'English',
        messages: {
          'simple': 'Hello',
          'with_arg': 'Hello {name}',
          'with_multiple': 'From {from} to {to}',
        },
      );

      i18n = LayrzAppLocalizations(
        languages: [language],
        currentLocale: const Locale('en'),
        fallbackLocale: const Locale('en'),
      );
      i18n.load().then((_) {});
    });

    tearDown(() {
      LayrzAppLocalizations.setDeveloperMode(false);
    });

    test('t() with plain key returns translated string', () {
      final result = i18n.t('simple');
      expect(result, equals('Hello'));
    });

    test('t() with single arg replaces {arg} marker', () {
      final result = i18n.t('with_arg', {'name': 'Alice'});
      expect(result, equals('Hello Alice'));
    });

    test('t() with multiple args replaces all markers', () {
      final result = i18n.t('with_multiple', {'from': 'A', 'to': 'Z'});
      expect(result, equals('From A to Z'));
    });
  });

  group('LayrzAppLocalizations.tc()', () {
    late LayrzAppLocalizations i18n;

    setUp(() {
      final language = AvailableLanguage(
        id: '1',
        code: 'en',
        name: 'English',
        messages: {
          'item_count': 'One item | Many items',
          'item_with_var': 'You have {count} item | You have {count} items',
          'single_form': 'Item',
          'with_plural': 'One apple | {count} apples',
        },
      );

      i18n = LayrzAppLocalizations(
        languages: [language],
        currentLocale: const Locale('en'),
        fallbackLocale: const Locale('en'),
      );
      i18n.load().then((_) {});
    });

    tearDown(() {
      LayrzAppLocalizations.setDeveloperMode(false);
    });

    test('tc() with val=1 returns first form', () {
      final result = i18n.tc('item_count', 1);
      expect(result, equals('One item'));
    });

    test('tc() with val=0 returns second form', () {
      final result = i18n.tc('item_count', 0);
      expect(result, equals('Many items'));
    });

    test('tc() with val=5 returns second form', () {
      final result = i18n.tc('item_count', 5);
      expect(result, equals('Many items'));
    });

    test('tc() with val=null returns second form (plural)', () {
      final result = i18n.tc('item_count', null);
      expect(result, equals('Many items'));
    });

    test('tc() with single form and val=1 returns that form', () {
      final result = i18n.tc('single_form', 1);
      expect(result, equals('Item'));
    });

    test('tc() with single form and val=0 returns that form', () {
      final result = i18n.tc('single_form', 0);
      expect(result, equals('Item'));
    });

    test('tc() with arg values containing pipe: arg is interpolated before selection', () {
      final result = i18n.tc('item_with_var', 1, {'count': 'a | b'});
      expect(result, equals('You have a | b item'));
    });

    test('tc() interpolates args before selecting plural form', () {
      final result = i18n.tc('with_plural', 1, {'count': '5'});
      expect(result, equals('One apple'));
    });

    test('tc() with val=3 selects second form and interpolates args', () {
      final result = i18n.tc('with_plural', 3, {'count': '3'});
      expect(result, equals('3 apples'));
    });
  });

  group('LayrzAppLocalizations.te()', () {
    late LayrzAppLocalizations i18n;

    setUp(() {
      final language = AvailableLanguage(
        id: '1',
        code: 'en',
        name: 'English',
        messages: {
          'plain': 'Hello World',
          'with_rich': 'Click [link]',
          'with_plain_and_rich': 'Say {text} to [user]',
        },
      );

      i18n = LayrzAppLocalizations(
        languages: [language],
        currentLocale: const Locale('en'),
        fallbackLocale: const Locale('en'),
      );
      i18n.load().then((_) {});
    });

    tearDown(() {
      LayrzAppLocalizations.setDeveloperMode(false);
    });

    test('te() returns TextSpan with text', () {
      final result = i18n.te('plain');
      expect(result, isA<TextSpan>());
      expect(result.text, equals('Hello World'));
    });

    test('te() with rich args returns TextSpan with children', () {
      final richSpan = TextSpan(text: 'Click here');
      final result = i18n.te('with_rich', richArgs: {'link': richSpan});

      expect(result, isA<TextSpan>());
      expect(result.children, isNotEmpty);
    });

    test('te() propagates style to TextSpan', () {
      const style = TextStyle(fontSize: 16, color: Color(0xFF000000));
      final result = i18n.te('plain', style: style);

      expect(result.style, equals(style));
    });

    test('te() with plain and rich args', () {
      final richSpan = TextSpan(text: 'Alice');
      final result = i18n.te(
        'with_plain_and_rich',
        args: {'text': 'Hi'},
        richArgs: {'user': richSpan},
      );

      expect(result, isA<TextSpan>());
      expect(result.children, isNotEmpty);
    });
  });

  group('LayrzAppLocalizations.tce()', () {
    late LayrzAppLocalizations i18n;

    setUp(() {
      final language = AvailableLanguage(
        id: '1',
        code: 'en',
        name: 'English',
        messages: {
          'msg': 'You have {count} [link] | You have {count} [links]',
          'no_form': '[link]',
        },
      );

      i18n = LayrzAppLocalizations(
        languages: [language],
        currentLocale: const Locale('en'),
        fallbackLocale: const Locale('en'),
      );
      i18n.load().then((_) {});
    });

    tearDown(() {
      LayrzAppLocalizations.setDeveloperMode(false);
    });

    test('tce() combines plural selection and rich rendering', () {
      final richSpan = TextSpan(text: 'here');
      final result = i18n.tce(
        'msg',
        1,
        args: {'count': '1'},
        richArgs: {'link': richSpan},
      );

      expect(result, isA<TextSpan>());
    });

    test('tce() selects second form for val!=1', () {
      final richSpan = TextSpan(text: 'here');
      final result = i18n.tce(
        'msg',
        3,
        args: {'count': '3'},
        richArgs: {'links': richSpan},
      );

      expect(result, isA<TextSpan>());
    });
  });

  group('LayrzAppLocalizations.hasTranslation()', () {
    late LayrzAppLocalizations i18n;

    setUp(() {
      final language = AvailableLanguage(
        id: '1',
        code: 'en',
        name: 'English',
        messages: {
          'exists': 'This key exists',
        },
      );

      i18n = LayrzAppLocalizations(
        languages: [language],
        currentLocale: const Locale('en'),
        fallbackLocale: const Locale('en'),
      );
      i18n.load().then((_) {});
    });

    test('hasTranslation() returns true for existing key', () {
      expect(i18n.hasTranslation('exists'), isTrue);
    });

    test('hasTranslation() returns false for missing key', () {
      expect(i18n.hasTranslation('missing'), isFalse);
    });
  });

  group('LayrzAppLocalizations fallback chain', () {
    late LayrzAppLocalizations i18n;

    setUp(() async {
      final current = AvailableLanguage(
        id: '1',
        code: 'en',
        name: 'English',
        messages: {
          'current_only': 'In current locale',
          'shared': 'From current',
        },
      );

      final fallback = AvailableLanguage(
        id: '2',
        code: 'fr',
        name: 'French (Fallback)',
        messages: {
          'fallback_only': 'In fallback locale',
          'shared': 'From fallback',
        },
      );

      i18n = LayrzAppLocalizations(
        languages: [current, fallback],
        currentLocale: const Locale('en'),
        fallbackLocale: const Locale('fr'),
      );
      await i18n.load();
    });

    tearDown(() {
      LayrzAppLocalizations.setDeveloperMode(false);
    });

    test('t() hits _messages for current locale key', () {
      final result = i18n.t('current_only');
      expect(result, equals('In current locale'));
    });

    test('t() falls back to _fallback when key not in _messages', () {
      final result = i18n.t('fallback_only');
      expect(result, equals('In fallback locale'));
    });

    test('t() returns default translation for "helpers.error.disaster"', () {
      final result = i18n.t('helpers.error.disaster');
      expect(result, equals('We are sorry, but something went wrong'));
    });

    test('t() returns default translation for "errors.not_found"', () {
      final result = i18n.t('errors.not_found');
      expect(result, equals('We are sorry, but the object you are looking for does not exist'));
    });

    test('t() returns "Translation missing key" for completely unknown key', () {
      final result = i18n.t('totally_unknown_key');
      expect(result, equals('Translation missing totally_unknown_key'));
    });
  });

  group('LayrzAppLocalizations developer mode', () {
    late LayrzAppLocalizations i18n;

    setUp(() async {
      final language = AvailableLanguage(
        id: '1',
        code: 'en',
        name: 'English',
        messages: {
          'key': 'Value',
        },
      );

      i18n = LayrzAppLocalizations(
        languages: [language],
        currentLocale: const Locale('en'),
        fallbackLocale: const Locale('en'),
      );
      await i18n.load();
    });

    tearDown(() {
      LayrzAppLocalizations.setDeveloperMode(false);
    });

    test('setDeveloperMode(true) changes t() output to debug format', () {
      LayrzAppLocalizations.setDeveloperMode(true);
      final result = i18n.t('key', {'arg': 'value'});
      expect(result, contains('key'));
      expect(result, contains('arg'));
    });

    test('setDeveloperMode(true) changes tc() output to debug format', () {
      LayrzAppLocalizations.setDeveloperMode(true);
      final result = i18n.tc('key', 1, {'arg': 'value'});
      expect(result, contains('key'));
      expect(result, contains('1'));
    });

    test('setDeveloperMode(true) changes te() output to debug format', () {
      LayrzAppLocalizations.setDeveloperMode(true);
      final result = i18n.te('key', args: {'arg': 'value'});
      expect(result.text, contains('key'));
    });

    test('setDeveloperMode(true) changes tce() output to debug format', () {
      LayrzAppLocalizations.setDeveloperMode(true);
      final result = i18n.tce('key', 1, args: {'arg': 'value'});
      expect(result.text, contains('key'));
    });

    test('setDeveloperMode(false) restores normal output', () {
      LayrzAppLocalizations.setDeveloperMode(true);
      LayrzAppLocalizations.setDeveloperMode(false);
      final result = i18n.t('key');
      expect(result, equals('Value'));
    });
  });

  group('LayrzAppLocalizations.translate() deprecated shim', () {
    late LayrzAppLocalizations i18n;

    setUp(() {
      final language = AvailableLanguage(
        id: '1',
        code: 'en',
        name: 'English',
        messages: {
          'key': 'Hello {name}',
        },
      );

      i18n = LayrzAppLocalizations(
        languages: [language],
        currentLocale: const Locale('en'),
        fallbackLocale: const Locale('en'),
      );
      i18n.load().then((_) {});
    });

    test('translate() delegates to t()', () {
      // ignore: deprecated_member_use_from_same_package
      final result = i18n.translate('key', {'name': 'World'});
      expect(result, equals('Hello World'));
    });
  });

  group('LayrzAppLocalizations.load()', () {
    test('load() populates _messages for matching locale', () async {
      final language = AvailableLanguage(
        id: '1',
        code: 'en',
        name: 'English',
        messages: {
          'key': 'value',
        },
      );

      final i18n = LayrzAppLocalizations(
        languages: [language],
        currentLocale: const Locale('en'),
        fallbackLocale: const Locale('en'),
      );

      await i18n.load();
      expect(i18n.hasTranslation('key'), isTrue);
    });

    test('load() returns empty map when locale has no matching language', () async {
      final language = AvailableLanguage(
        id: '1',
        code: 'fr',
        name: 'French',
        messages: {
          'key': 'valeur',
        },
      );

      final i18n = LayrzAppLocalizations(
        languages: [language],
        currentLocale: const Locale('en'),
        fallbackLocale: const Locale('en'),
      );

      await i18n.load();
      expect(i18n.hasTranslation('key'), isFalse);
    });

    test('load() populates _fallback from fallback locale', () async {
      final fallback = AvailableLanguage(
        id: '1',
        code: 'en',
        name: 'English',
        messages: {
          'fallback_key': 'fallback_value',
        },
      );

      final i18n = LayrzAppLocalizations(
        languages: [fallback],
        currentLocale: const Locale('fr'),
        fallbackLocale: const Locale('en'),
      );

      await i18n.load();
      final result = i18n.t('fallback_key');
      expect(result, equals('fallback_value'));
    });
  });
}
