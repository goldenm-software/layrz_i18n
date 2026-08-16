## 0.0.1

- Initial release: the i18n engine extracted from `layrz_models` into a standalone package with performance optimizations
- **Note**: Depends on the Flutter SDK, `freezed_annotation`, `json_annotation`, `collection`, and `web`. No dependency on Material Design or layrz_models; works with WidgetsApp and custom widget trees.
- **New**: Single-pass tokenizer with template caching for efficient message rendering
- **New**: Content-keyed template cache (up to 1,024 entries) — entries never stale across locale switches
- **New**: Optimized `load()` method using locale-keyed index instead of repeated locale parsing
- **Change**: `tc()` now splits plural forms before interpolating (fixes corruption when argument values contain ' | ')
- **Change**: `shouldReload()` now compares delegates by value instead of always returning true
- **Change**: Removed unused `padding` parameter from `te()`
- **Change**: `AvailableLanguage.messages` map returned as-is (not wrapped in `EqualUnmodifiableMapView`) for performance — avoids allocations on the hottest path (every translate call); callers must not mutate it
- **Fix**: Fixed locale parsing bug where `'en-'` and `'en_'` produced invalid `Locale('en','')`
