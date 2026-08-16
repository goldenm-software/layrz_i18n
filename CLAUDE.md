# layrz_i18n — Claude Code guide

Runtime internationalization engine for Flutter. Translations are loaded at runtime from a
backend or assets — not compiled from ARB files at build time. Provides plurals, rich-text
interpolation, locale detection, and a `LocalizationsDelegate`.

Originally extracted from `layrz_models/lib/src/i18n/`. That copy still exists there and is
unmodified; this package is standalone and does **not** depend on it.

## Hard invariants

Break any of these and CI fails.

1. **No Material, no Cupertino.** `lib/` imports `package:flutter/widgets.dart` and
   `package:flutter/foundation.dart` only. This is the package's entire selling point — it must
   work under a bare `WidgetsApp`. Enforced by `make checks` and by a grep guard in
   `.github/workflows/checks.yaml`. This applies to tests, the example, and code samples in docs.
2. **No dependency on `layrz_models` or `layrz_logging`.** The admin-side models (`I18nKey`,
   `I18nTranslation`, `Language`, `I18nKeyHistory`) and `AvailableLanguage.fetchAll()` were
   deliberately left behind in `layrz_models`. Do not port them here — that would recreate the
   circular dependency this package exists to remove.
3. **Coverage floor is 90%.** Currently ~94.7%.
4. **Commits must be GPG-signed** (org ruleset). Signing is configured globally; don't disable it.

## Layout

Plain files with an export barrel — **not** the `library` + `part`/`part of` pattern.

```
lib/layrz_i18n.dart          # pure exports, nothing else
lib/src/engine/
  localizations.dart         # LayrzI18n — t/tc/te/tce, load, of/maybeOf
  delegate.dart              # LayrzI18nDelegate, debugCheckHasLayrzI18n
  context_extension.dart     # context.i18n / context.maybeI18n
  locale_resolver.dart       # getClosestLocale, detectedLocale, conditional platform import
  template.dart              # tokenizer + compiled-template cache (hot path)
  detection/native.dart|web.dart
lib/src/models/              # AvailableLanguage (freezed), SavedLanguage (plain)
lib/src/utils/locale_parser.dart   # parseLocale — the single canonical locale parser
```

Every file under `src/` is its own library with its own imports. The only `part` directives are
freezed/json_serializable's own output in `models/available_language.dart`. Files stay under
~400 lines; split by responsibility rather than appending.

Because each file is a separate library, `_`-prefixed symbols are **not** visible across files.
Cross-file internals drop the underscore and simply aren't exported from the barrel.

## Commands

```bash
make checks          # what the pre-commit hook and CI run — do this before pushing
make install-hooks   # one-time: activates .githooks (sets core.hooksPath)
make freezed         # dart run build_runner build
make test            # flutter test (116 tests)
make coverage        # strips generated files, then reports the percentage
make bench           # flutter test --tags benchmark
```

## Traps

**`.pubignore` REPLACES `.gitignore` for publishing — it does not merge with it.** Anything that
must stay out of the pub.dev archive has to be listed in `.pubignore` explicitly, including build
output. Getting this wrong once produced a 28 MB archive full of `build/` and `.dart_tool/`.
Always sanity-check with `flutter pub publish --dry-run` — expect **~14 KB and 0 warnings**.

**Coverage must be measured through the strip script.** Raw lcov counts the generated
`available_language.freezed.dart` and reports ~79%, which fails the gate. The real number comes
from:

```bash
flutter test --coverage
dart run tool/strip_ignored_coverage.dart coverage/lcov.info
awk -F'[:,]' '/^DA:/ {t++; if ($3 != 0) h++} END {printf "%.2f%%\n", h*100/t}' coverage/lcov.info
```

`layrz-actions`' `coverage-check` applies **no exclusions of its own** — it counts every `DA:`
line — so the workflow has to run the strip script itself before calling it. `make checks` and the
CI `coverage` job both do.

**Never hand-edit generated files.** `.freezed.dart` carries freezed's own `// coverage:ignore-file`
and regenerates with it intact. `.g.dart` does **not** get one — json_serializable never emits it,
and adding one by hand is destroyed on the next `build_runner` run, silently dropping coverage
below the gate. `.g.dart` lines are covered by real `fromJson`/`toJson` round-trip tests instead.

**`AvailableLanguage` uses `@Freezed(makeCollectionsUnmodifiable: false)` deliberately.** The
default wraps `messages` in an `EqualUnmodifiableMapView` on every getter access, which would sit
directly on the hottest path (`_raw()` runs on essentially every widget build). The tradeoff is
that `messages` is mutable — the engine only ever reads it.

**A bare `WidgetsApp` is not a `MaterialApp`.** It requires `color:`, provides no `Directionality`,
and asserts that `pageRouteBuilder` is set if you pass `home`/`routes`. `example/lib/main.dart`
sidesteps this by using `builder:` with a `Directionality`. `flutter analyze` catches none of it —
only mounting the tree in a widget test does.

## Performance

`t()` runs on essentially every widget build. `template.dart` parses each message once into tokens
and caches by **raw message string** (not by key or locale — content-keying means entries can never
go stale, and a fresh `LayrzI18n` is constructed on every delegate `load()`). Both marker syntaxes
(`{plain}` and `[rich]`) are handled in a single pass.

Do not reintroduce per-argument `replaceAll` or a recursive rich-text replacer; the originals were
O(n·args) and cubic respectively. `test/benchmark_test.dart` keeps a copy of the old algorithms and
prints an old-vs-new table (`make bench`) — 34× on `te()` with 5 rich args.

## Docs

Usage documentation lives in the **GitHub Wiki**, a git submodule at `wiki/` (separate repo,
branch `master`). The README intentionally keeps only badges, pitch, wiki links and the FAQ.

After editing wiki pages: commit and push inside `wiki/`, then bump the submodule pointer in a
separate commit here. Links are plain `[text](Page-Name)` with no `.md` extension.

`example/lib/main.dart` is the source of truth for code samples in the README and wiki — it
compiles and has a widget test. Copy from it rather than writing samples by hand.

## Git and release

Work on `development`; reach `main` via PR. `main` requires a PR, code-owner review, signed
commits, and the `lint-dart` + `coverage` checks — direct pushes are rejected.

Pushing a `v*.*.*` tag triggers `.github/workflows/publish.yaml`, which runs
`flutter pub publish --force`. **A tag is a real publish to pub.dev.** Bump `pubspec.yaml` and add
the CHANGELOG section *before* tagging — the workflow publishes whatever version the pubspec says,
not what the tag says, and its precheck requires the tagged commit to be an ancestor of
`origin/main`.

## Public API

`LayrzI18n` (`t`, `tc`, `te`, `tce`, `hasTranslation`, deprecated `translate`, `of`, `maybeOf`,
`getClosestLocale`, `setDeveloperMode`, `developerMode`, `detectedLocale`, `delegate`, `load`),
`LayrzI18nDelegate`, `debugCheckHasLayrzI18n`, `AvailableLanguage`, `SavedLanguage`, `parseLocale`,
and the `context.i18n` / `context.maybeI18n` extension.

Renamed in 1.0.0 from `LayrzAppLocalizations` / `LayrzAppLocalizationsDelegate` /
`debugCheckHasLayrzAppLocalizations`. See `wiki/Migration-From-layrz_models.md`.

Message syntax: `{name}` plain args, `[name]` rich args → `InlineSpan`, ` | ` separates singular
from plural. A missing arg renders the literal `{name}`; a null value renders `"null"`; `t()` on a
plural message returns the whole string including ` | ` — only `tc()`/`tce()` select a form.
