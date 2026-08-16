import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:layrz_i18n/layrz_i18n.dart';

void main() {
  group('LayrzI18nContextExtension', () {
    testWidgets('context.i18n resolves and returns the instance', (WidgetTester tester) async {
      final languages = [
        AvailableLanguage(
          id: '1',
          code: 'en',
          name: 'English',
          messages: const {
            'test_key': 'Test message',
          },
        ),
      ];

      final delegate = LayrzAppLocalizations.delegate(
        languages: languages,
        supportedLocales: const [Locale('en')],
        fallbackLocale: const Locale('en'),
      );

      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFFFFFFFF),
          localizationsDelegates: [delegate],
          supportedLocales: const [Locale('en')],
          builder: (BuildContext context, Widget? child) {
            // This should resolve without error and call t()
            final translation = context.i18n.t('test_key');
            return Text(translation);
          },
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test message'), findsOneWidget);
    });

    testWidgets('context.i18n.tc() works through the extension', (WidgetTester tester) async {
      final languages = [
        AvailableLanguage(
          id: '1',
          code: 'en',
          name: 'English',
          messages: const {
            'items': 'One item | {count} items',
          },
        ),
      ];

      final delegate = LayrzAppLocalizations.delegate(
        languages: languages,
        supportedLocales: const [Locale('en')],
        fallbackLocale: const Locale('en'),
      );

      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFFFFFFFF),
          localizationsDelegates: [delegate],
          supportedLocales: const [Locale('en')],
          builder: (BuildContext context, Widget? child) {
            // Verify that the extension returns the real instance by calling tc()
            final translation = context.i18n.tc('items', 5, {'count': '5'});
            return Text(translation);
          },
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('5 items'), findsOneWidget);
    });

    testWidgets('context.maybeI18n returns the instance when present', (WidgetTester tester) async {
      final languages = [
        AvailableLanguage(
          id: '1',
          code: 'en',
          name: 'English',
          messages: const {
            'test_key': 'Test message',
          },
        ),
      ];

      final delegate = LayrzAppLocalizations.delegate(
        languages: languages,
        supportedLocales: const [Locale('en')],
        fallbackLocale: const Locale('en'),
      );

      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFFFFFFFF),
          localizationsDelegates: [delegate],
          supportedLocales: const [Locale('en')],
          builder: (BuildContext context, Widget? child) {
            final i18n = context.maybeI18n;
            return Text(i18n != null ? 'Has i18n' : 'No i18n');
          },
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Has i18n'), findsOneWidget);
    });

    testWidgets('context.maybeI18n returns null when not present', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFFFFFFFF),
          builder: (BuildContext context, Widget? child) {
            final i18n = context.maybeI18n;
            return Text(i18n == null ? 'No i18n' : 'Has i18n');
          },
        ),
      );

      expect(find.text('No i18n'), findsOneWidget);
    });

    testWidgets('context.i18n throws when LayrzAppLocalizations not present', (WidgetTester tester) async {
      late String errorMessage;

      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFFFFFFFF),
          builder: (BuildContext context, Widget? child) {
            try {
              // This should throw because LayrzAppLocalizations is not in the tree
              final _ = context.i18n;
              return const Text('No error');
            } on FlutterError catch (e) {
              errorMessage = e.message;
              return Text(errorMessage);
            }
          },
        ),
      );

      // Verify that it threw and the error message is about LayrzAppLocalizations not being initialized
      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is Text &&
              widget.data != null &&
              widget.data!.contains('LayrzAppLocalizations was used before it was initialized'),
        ),
        findsOneWidget,
      );
    });
  });
}
