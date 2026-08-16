# Layrz I18n

[![Pub version](https://img.shields.io/pub/v/layrz_i18n?logo=flutter)](https://pub.dev/packages/layrz_i18n)
[![likes](https://img.shields.io/pub/likes/layrz_i18n?logo=flutter)](https://pub.dev/packages/layrz_i18n/score)
[![GitHub license](https://img.shields.io/github/license/goldenm-software/layrz_i18n?logo=github)](https://github.com/goldenm-software/layrz_i18n)

A lightweight internationalization (i18n) engine for Flutter — runtime translations loaded from your own backend or assets, plural forms, rich-text interpolation and automatic locale detection. Imports only `package:flutter/widgets.dart` — no Material or Cupertino — so it works under a bare `WidgetsApp`. Runs on every platform Flutter supports, including web.

## Documentation

Complete documentation is available on the [layrz_i18n wiki](https://github.com/goldenm-software/layrz_i18n/wiki):

- **[Getting Started](https://github.com/goldenm-software/layrz_i18n/wiki/Getting-Started)** — Installation and basic setup
- **[Message Syntax](https://github.com/goldenm-software/layrz_i18n/wiki/Message-Syntax)** — Translation keys, placeholders, and pluralization
- **[Context Extension](https://github.com/goldenm-software/layrz_i18n/wiki/Context-Extension)** — Accessing translations via `context.i18n`
- **[Locale Detection](https://github.com/goldenm-software/layrz_i18n/wiki/Locale-Detection)** — Automatic language selection and fallbacks
- **[Developer Mode](https://github.com/goldenm-software/layrz_i18n/wiki/Developer-Mode)** — Debugging translations in development

## FAQ

### Is this the same as the i18n engine in `layrz_models`?

Yes in origin: this package is that engine extracted into a standalone package, optimized, and freed of its `layrz_models` dependency. **Note**: Migrating from `layrz_models` requires renaming the main classes — `LayrzAppLocalizations` is now `LayrzI18n`, and `LayrzAppLocalizationsDelegate` is now `LayrzI18nDelegate`. The `debugCheckHasLayrzAppLocalizations` function is now `debugCheckHasLayrzI18n`. See the [CHANGELOG](CHANGELOG.md) for full details on breaking changes.

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
