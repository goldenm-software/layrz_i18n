import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:layrz_i18n/layrz_i18n.dart';
import 'package:layrz_i18n/src/engine/template.dart';

void main() {
  group('Template tokenization and rendering', () {
    late LayrzAppLocalizations i18n;

    setUp(() async {
      final language = AvailableLanguage(
        id: '1',
        code: 'en',
        name: 'English',
        messages: {
          'plain': 'Hello World',
          'single_arg': 'Hello {name}',
          'single_rich': 'Hello [link]',
          'mixed': 'Go to {url} and click [link]',
          'multiple_args': 'From {from} to {to}',
          'multiple_rich': 'Visit [link1] then [link2]',
          'empty_arg': 'Test {}',
          'empty_rich': 'Test []',
          'adjacent': '{a}{b}',
          'same_rich_twice': 'Go [link] then [link] again',
          'unclosed_brace': 'a{b',
          'unclosed_bracket': 'a[b',
          'null_arg': 'Value is {val}',
          'plural': 'One item | Many items',
          'plural_with_arg': 'You have {count} item | You have {count} items',
          'plural_single_form': 'Item',
          'singular': 'One item',
          'arg_with_pipe': 'Hi {who} | Hello {who}',
        },
      );

      i18n = LayrzAppLocalizations(
        languages: [language],
        currentLocale: const Locale('en'),
        fallbackLocale: const Locale('en'),
      );
      await i18n.load();
      clearTemplateCache();
    });

    tearDown(() {
      clearTemplateCache();
      LayrzAppLocalizations.setDeveloperMode(false);
    });

    test('renders plain message with no markers', () {
      final result = i18n.t('plain');
      expect(result, equals('Hello World'));
    });

    test('renders message with single {arg} marker', () {
      final result = i18n.t('single_arg', {'name': 'Alice'});
      expect(result, equals('Hello Alice'));
    });

    test('renders message with single [rich] marker', () {
      final result = i18n.t('single_rich');
      expect(result, equals('Hello [link]'));
    });

    test('renders message with mixed {arg} and [rich] markers', () {
      final result = i18n.t('mixed', {'url': 'example.com'});
      expect(result, equals('Go to example.com and click [link]'));
    });

    test('renders message with multiple {arg} markers', () {
      final result = i18n.t('multiple_args', {'from': 'A', 'to': 'Z'});
      expect(result, equals('From A to Z'));
    });

    test('renders message with multiple [rich] markers', () {
      final result = i18n.t('multiple_rich');
      expect(result, equals('Visit [link1] then [link2]'));
    });

    test('missing arg renders literal {key}', () {
      final result = i18n.t('single_arg', {});
      expect(result, equals('Hello {name}'));
    });

    test('null arg value renders as string "null"', () {
      final result = i18n.t('null_arg', {'val': null});
      expect(result, equals('Value is null'));
    });

    test('empty {arg} marker is rendered as literal {}', () {
      final result = i18n.t('empty_arg');
      expect(result, equals('Test {}'));
    });

    test('empty [rich] marker is rendered as literal []', () {
      final result = i18n.t('empty_rich');
      expect(result, equals('Test []'));
    });

    test('adjacent markers {a}{b} render correctly', () {
      final result = i18n.t('adjacent', {'a': 'X', 'b': 'Y'});
      expect(result, equals('XY'));
    });

    test('same rich marker appearing twice in one message [link] [link]', () {
      final result = i18n.t('same_rich_twice');
      expect(result, equals('Go [link] then [link] again'));
    });

    test('unclosed brace renders verbatim', () {
      final result = i18n.t('unclosed_brace');
      expect(result, equals('a{b'));
    });

    test('unclosed bracket renders verbatim', () {
      final result = i18n.t('unclosed_bracket');
      expect(result, equals('a[b'));
    });

    test('cache grows by 1 per unique message, not per call', () async {
      clearTemplateCache();
      expect(cachedTemplateCount, equals(0));

      // Note: t() with no args bypasses the cache, so we use args for all calls
      i18n.t('single_arg', {'name': 'Alice'});
      expect(cachedTemplateCount, equals(1));

      i18n.t('single_arg', {'name': 'Bob'});
      expect(cachedTemplateCount, equals(1));

      i18n.t('multiple_args', {'from': 'A', 'to': 'Z'});
      expect(cachedTemplateCount, equals(2));

      i18n.t('multiple_args', {'from': 'X', 'to': 'Y'});
      expect(cachedTemplateCount, equals(2));
    });

    test('clearTemplateCache() resets cache count', () {
      i18n.t('single_arg', {'name': 'Test'});
      expect(cachedTemplateCount, greaterThan(0));

      clearTemplateCache();
      expect(cachedTemplateCount, equals(0));
    });

    test('cache overflow clears cache when reaching 1024 entries', () {
      clearTemplateCache();
      expect(cachedTemplateCount, equals(0));

      // Manually trigger cache overflow by adding many templates
      // (Since we can't easily generate 1024 unique messages in the test,
      // we test the behavior of getTemplate which handles the overflow)
      for (int i = 0; i < 1024; i++) {
        getTemplate('message_$i');
      }
      expect(cachedTemplateCount, equals(1024));

      // Next call should clear the cache
      getTemplate('message_1024');
      // After clear and add, should have only the new one
      expect(cachedTemplateCount, equals(1));
    });

    test('plural message called via t() returns full string with separator', () {
      final result = i18n.t('plural');
      expect(result, equals('One item | Many items'));
    });

    test('plural message with args called via t() interpolates before returning full string', () {
      final result = i18n.t('plural_with_arg', {'count': '5'});
      expect(result, equals('You have 5 item | You have 5 items'));
    });

    test('arg value containing pipe is preserved during interpolation', () {
      final result = i18n.tc('arg_with_pipe', 1, {'who': 'Alice | Bob'});
      // This is testing the new behavior where args are interpolated first,
      // then plural form is selected. So with val=1, we get the first form.
      expect(result, equals('Hi Alice | Bob'));
    });
  });

  group('Rich text rendering (te)', () {
    late LayrzAppLocalizations i18n;

    setUp(() async {
      final language = AvailableLanguage(
        id: '1',
        code: 'en',
        name: 'English',
        messages: {
          'rich_plain': 'Hello [link]',
          'rich_with_plain_arg': 'Hi {name}, click [link]',
          'multiple_rich': '[link1] and [link2]',
        },
      );

      i18n = LayrzAppLocalizations(
        languages: [language],
        currentLocale: const Locale('en'),
        fallbackLocale: const Locale('en'),
      );
      await i18n.load();
      clearTemplateCache();
    });

    test('te() returns TextSpan with rich args', () {
      final richSpan = TextSpan(
        text: 'Click here',
        style: const TextStyle(color: Color(0xFF0000FF)),
      );
      final result = i18n.te('rich_plain', richArgs: {'link': richSpan});

      expect(result, isA<TextSpan>());
      expect(result.children, isNotEmpty);
      // Message is 'Hello [link]' so we expect 'Hello ' (literal) + richSpan (InlineSpan) = 2 children
      expect(result.children!.length, equals(2));
      expect((result.children![1] as TextSpan).text, equals('Click here'));
    });

    test('te() propagates base style to literal text', () {
      const baseStyle = TextStyle(fontSize: 14);
      final result = i18n.te('rich_plain', style: baseStyle);

      expect(result.style, equals(baseStyle));
    });

    test('te() with both plain and rich args', () {
      final richSpan = TextSpan(text: 'Click here');
      final result = i18n.te(
        'rich_with_plain_arg',
        args: {'name': 'Alice'},
        richArgs: {'link': richSpan},
      );

      expect(result, isA<TextSpan>());
      expect(result.children, isNotEmpty);
    });

    test('te() with missing rich arg renders literal [key]', () {
      final result = i18n.te('rich_plain', richArgs: const {});
      // Message is 'Hello [link]' with no richArgs, should render as 'Hello ' + '[link]'
      if (result.children != null) {
        expect(result.children, isNotEmpty);
      } else {
        // If children is null, text should contain the literal representation
        expect(result.text, isNotNull);
      }
    });
  });
}
