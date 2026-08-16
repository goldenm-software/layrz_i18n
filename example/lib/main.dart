import 'package:flutter/widgets.dart';
import 'package:layrz_i18n/layrz_i18n.dart';

void main() {
  runApp(const MyApp());
}

final languages = [
  AvailableLanguage(
    id: '1',
    name: 'English',
    code: 'en',
    fallback: 'en',
    messages: {'greeting': 'Hello, {name}!', 'items': 'One item | {count} items', 'welcome': 'Welcome to [link]'},
  ),
  AvailableLanguage(
    id: '2',
    name: 'Español',
    code: 'es',
    fallback: 'en',
    messages: {
      'greeting': '¡Hola, {name}!',
      'items': 'Un elemento | {count} elementos',
      'welcome': 'Bienvenido a [link]',
    },
  ),
];

final supportedLocales = languages.map((l) => l.getLocale()).toList();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      color: const Color(0xFF000000),
      locale: LayrzI18n.getClosestLocale(supportedLocales: supportedLocales, fallbackLocale: const Locale('en')),
      localizationsDelegates: [
        LayrzI18n.delegate(
          languages: languages,
          supportedLocales: supportedLocales,
          fallbackLocale: const Locale('en'),
        ),
      ],
      supportedLocales: supportedLocales,
      builder: (BuildContext context, Widget? child) {
        return Directionality(textDirection: TextDirection.ltr, child: const HomePage());
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(context.i18n.t('greeting', {'name': 'Alice'})),
        Text(context.i18n.tc('items', 5, {'count': '5'})),
        RichText(
          text: context.i18n.te('welcome', richArgs: {'link': TextSpan(text: 'our site')}),
        ),
      ],
    );
  }
}
