# Layrz I18n

[![Pub version](https://img.shields.io/pub/v/layrz_i18n?logo=flutter)](https://pub.dev/packages/layrz_i18n)
[![likes](https://img.shields.io/pub/likes/layrz_i18n?logo=flutter)](https://pub.dev/packages/layrz_i18n/score)
[![GitHub license](https://img.shields.io/github/license/goldenm-software/layrz_i18n?logo=github)](https://github.com/goldenm-software/layrz_i18n)

A lightweight internationalization (i18n) engine for Flutter — runtime translations loaded from your own backend or assets, plural forms, rich-text interpolation and automatic locale detection. Imports only `package:flutter/widgets.dart` — no Material or Cupertino — so it works under a bare `WidgetsApp`. Runs on every platform Flutter supports, including web.

## Usage

Define your languages with translated messages:

```dart
final languages = [
  AvailableLanguage(
    id: '1',
    name: 'English',
    code: 'en',
    fallback: 'en',
    messages: {
      'greeting': 'Hello, {name}!',
      'items': 'One item | {count} items',
      'welcome': 'Welcome to [link]',
    },
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
```

Wire the localizations delegate into your `WidgetsApp`:

```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      color: const Color(0xFF000000),
      locale: LayrzAppLocalizations.getClosestLocale(
        supportedLocales: supportedLocales,
        fallbackLocale: const Locale('en'),
      ),
      localizationsDelegates: [
        LayrzAppLocalizations.delegate(
          languages: languages,
          supportedLocales: supportedLocales,
          fallbackLocale: const Locale('en'),
        ),
      ],
      supportedLocales: supportedLocales,
      builder: (BuildContext context, Widget? child) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: const HomePage(),
        );
      },
    );
  }
}
```

Translate strings in your widgets:

```dart
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(context.i18n.t('greeting', {'name': 'Alice'})),
        Text(context.i18n.tc('items', 5, {'count': '5'})),
        RichText(text: context.i18n.te('welcome', richArgs: {'link': TextSpan(text: 'our site')})),
      ],
    );
  }
}
```

Alternatively, you can use `LayrzAppLocalizations.of(context)` for the explicit form:

```dart
final i18n = LayrzAppLocalizations.of(context);
Text(i18n.t('greeting', {'name': 'Alice'}))
```

## Message syntax

| Syntax | Purpose | Example |
|--------|---------|---------|
| `{key}` | Plain-text argument marker | `'Hello, {name}!'` → `'Hello, Alice!'` with `t()` |
| `[key]` | Rich-text argument (resolved to `InlineSpan`) | `'Click [link]'` → `TextSpan` with rich argument via `te()` |
| ` \| ` | Plural form separator (singular \| plural) | `'One item \| {count} items'` with `tc()` or `tce()` |

**Translation methods:**
- `t(key, args)` → `String`: translate with plain-text arguments
- `tc(key, count, args)` → `String`: pluralize and translate with plain-text arguments
- `te(key, args, richArgs, style)` → `TextSpan`: translate with rich-text arguments
- `tce(key, count, args, richArgs, style)` → `TextSpan`: pluralize and translate with rich-text arguments

## FAQ

### Is this the same as the i18n engine in `layrz_models`?

Yes in origin: this package is that engine extracted into a standalone package, optimized, and freed of its `layrz_models` dependency. The public API is source-compatible, so migrating is an import change. See the [CHANGELOG](CHANGELOG.md) for intentional improvements and breaking changes.

### Why is this package called `layrz_i18n`?

All packages developed by [Layrz](https://layrz.com) are prefixed with `layrz_`, check out our other packages on [pub.dev](https://pub.dev/publishers/goldenm.com/packages).

### Why this library exists?

We built this library to support Layrz applications that load translations from a backend at runtime rather than compiling static translation files at build time, then shared it with the community.

### Do you have other libraries?

Of course! We have multiple libraries (for Layrz or general purpose) that you can use in your projects, you can find us on [PyPi](https://pypi.org/user/goldenm/) for Python libraries, [RubyGems](https://rubygems.org/profiles/goldenm) for Ruby gems, [NPM of Golden M](https://www.npmjs.com/~goldenm) or [NPM of Layrz](https://www.npmjs.com/~layrz-software) for NodeJS libraries or here in [Pub.dev](https://pub.dev/publishers/goldenm.com/packages) for Dart/Flutter libraries.

### I need to pay to use this package?

**No!** This library is free and open source, you can use it in your projects without any cost, but if you want to support us, give us a thumbs up here in [pub.dev](https://pub.dev/packages/layrz_i18n) and star our [Repository](https://github.com/goldenm-software/layrz_i18n)!

### Can I contribute to this package?

**Yes!** We are open to contributions, feel free to open a pull request or an issue on the [Repository](https://github.com/goldenm-software/layrz_i18n)!

### I have a question, how can I contact you?

If you need more assistance, you can open an issue on the [Repository](https://github.com/goldenm-software/layrz_i18n) and we're happy to help you :)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Who are you? / Want to work with us?

**Golden M** is a software and hardware development company what is working on a new, innovative and disruptive technologies. For more information, contact us at [sales@goldenm.com](mailto:sales@goldenm.com) or via WhatsApp at [+(507)-6979-3073](https://wa.me/50769793073?text="From%20layrz_i18n%20flutter%20library.%20Hello").
