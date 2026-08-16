@Tags(['benchmark'])
// ignore_for_file: avoid_print
library;

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:layrz_i18n/layrz_i18n.dart';
import 'package:layrz_i18n/src/engine/template.dart';

// ===== BASELINE IMPLEMENTATION (Original Algorithm) =====
//
// This reproduces the original engine's behavior for comparison.
// The original used:
// 1. replaceAll() per argument for plain text interpolation (t)
// 2. Recursive _deepReplace + _requiresDeep for rich text (te)

class _BaselineOldEngine {
  final Map<String, String> messages;

  _BaselineOldEngine(this.messages);

  /// Original t() using replaceAll per arg
  String t(String key, [Map<String, dynamic> args = const {}]) {
    String res = messages[key] ?? 'Translation missing $key';

    args.forEach((key, value) {
      res = res.replaceAll('{$key}', '$value');
    });

    return res;
  }

  /// Original tc() splitting on ' | ' and using t()
  String tc(String key, int? val, [Map<String, dynamic> args = const {}]) {
    final List<String> rawTranslation = t(key, args).split(' | ');

    if (val == null) {
      if (rawTranslation.length == 1) {
        return rawTranslation.first;
      } else {
        return rawTranslation[1];
      }
    }

    if (val == 1) {
      return rawTranslation[0];
    }

    if (rawTranslation.length == 1) {
      return rawTranslation.first;
    } else {
      return rawTranslation[1];
    }
  }

  /// Original te() using _deepReplace
  TextSpan te(
    String key, {
    Map<String, dynamic> args = const {},
    Map<String, InlineSpan> richArgs = const {},
    TextStyle? style,
  }) {
    final String baseText = t(key, args);

    final items = _deepReplace(items: [baseText], richArgs: richArgs, style: style);

    return TextSpan(
      children: items
          .map((item) {
            if (item is String) return TextSpan(text: item, style: style);
            if (item is InlineSpan) return item;
            return null;
          })
          .whereType<InlineSpan>()
          .toList(),
      style: style,
    );
  }

  /// Original recursive _deepReplace
  List<dynamic> _deepReplace({
    required List<dynamic> items,
    required Map<String, InlineSpan> richArgs,
    TextStyle? style,
  }) {
    if (_requiresDeep(items: items, vars: richArgs.keys.toList())) {
      final entry = richArgs.entries.firstWhereOrNull((entry) {
        return items.any((item) {
          if (item is String) {
            return item.contains('[${entry.key}]');
          }
          return false;
        });
      });

      if (entry == null) return items;

      for (int i = 0; i < items.length; i++) {
        if (items[i] is String) {
          if (items[i].contains('[${entry.key}]')) {
            final removed = items.removeAt(i);
            final parts = removed.split('[${entry.key}]');

            items.insert(i, parts[0]);
            items.insert(i + 1, entry.value);
            items.insert(i + 2, parts.sublist(1).join('[${entry.key}]'));
            break;
          }
        }
      }
      return _deepReplace(items: items, richArgs: richArgs, style: style);
    }
    return items;
  }

  /// Original _requiresDeep
  bool _requiresDeep({required List<dynamic> items, required List<String> vars}) {
    for (var item in items) {
      if (item is String) {
        for (var varName in vars) {
          if (item.contains('[$varName]')) {
            return true;
          }
        }
      }
    }
    return false;
  }
}

// ===== BENCHMARK TESTS =====

void main() {
  group('Benchmarks - Performance Comparison', () {
    late LayrzAppLocalizations i18n;
    late _BaselineOldEngine baseline;
    late Map<String, String> testMessages;

    setUpAll(() {
      // Build messages with ~500 keys for realistic load
      testMessages = {
        'plain': 'Hello World',
        'single_arg': 'Hello {name}',
        'two_args': 'From {from} to {to}',
        'three_args': '{a} and {b} and {c}',
        'plural': 'One item | Many items',
        'plural_arg': 'You have {n} item | You have {n} items',
        'rich_single': 'Click [link]',
        'rich_multiple': '[a] and [b] and [c] and [d] and [e]',
      };

      // Add 500 more keys for realistic cache behavior
      for (int i = 0; i < 500; i++) {
        testMessages['generated_key_$i'] = 'Message $i with {val}';
      }

      final language = AvailableLanguage(
        id: '1',
        code: 'en',
        name: 'English',
        messages: testMessages,
      );

      i18n = LayrzAppLocalizations(
        languages: [language],
        currentLocale: const Locale('en'),
        fallbackLocale: const Locale('en'),
      );

      baseline = _BaselineOldEngine(testMessages);
    });

    test('t() with 0 args - comparison', () async {
      await i18n.load();
      clearTemplateCache();

      // New implementation
      final stopNew = Stopwatch()..start();
      for (int i = 0; i < 10000; i++) {
        i18n.t('plain');
      }
      stopNew.stop();

      // Baseline
      final stopOld = Stopwatch()..start();
      for (int i = 0; i < 10000; i++) {
        baseline.t('plain');
      }
      stopOld.stop();

      final ratio = stopOld.elapsedMilliseconds / stopNew.elapsedMilliseconds;
      print('t() with 0 args x10000:');
      print('  New:      ${stopNew.elapsedMilliseconds}ms');
      print('  Baseline: ${stopOld.elapsedMilliseconds}ms');
      print('  Speedup:  ${ratio.toStringAsFixed(2)}x');
    });

    test('t() with 1 arg - comparison', () async {
      clearTemplateCache();

      final args = {'name': 'Alice'};

      // New implementation
      final stopNew = Stopwatch()..start();
      for (int i = 0; i < 10000; i++) {
        i18n.t('single_arg', args);
      }
      stopNew.stop();

      // Baseline
      final stopOld = Stopwatch()..start();
      for (int i = 0; i < 10000; i++) {
        baseline.t('single_arg', args);
      }
      stopOld.stop();

      final ratio = stopOld.elapsedMilliseconds / stopNew.elapsedMilliseconds;
      print('t() with 1 arg x10000:');
      print('  New:      ${stopNew.elapsedMilliseconds}ms');
      print('  Baseline: ${stopOld.elapsedMilliseconds}ms');
      print('  Speedup:  ${ratio.toStringAsFixed(2)}x');
    });

    test('t() with 3 args - comparison', () async {
      clearTemplateCache();

      final args = {'a': 'X', 'b': 'Y', 'c': 'Z'};

      // New implementation
      final stopNew = Stopwatch()..start();
      for (int i = 0; i < 10000; i++) {
        i18n.t('three_args', args);
      }
      stopNew.stop();

      // Baseline
      final stopOld = Stopwatch()..start();
      for (int i = 0; i < 10000; i++) {
        baseline.t('three_args', args);
      }
      stopOld.stop();

      final ratio = stopOld.elapsedMilliseconds / stopNew.elapsedMilliseconds;
      print('t() with 3 args x10000:');
      print('  New:      ${stopNew.elapsedMilliseconds}ms');
      print('  Baseline: ${stopOld.elapsedMilliseconds}ms');
      print('  Speedup:  ${ratio.toStringAsFixed(2)}x');
    });

    test('tc() plural selection - comparison', () async {
      clearTemplateCache();

      final args = {'n': '5'};

      // New implementation
      final stopNew = Stopwatch()..start();
      for (int i = 0; i < 10000; i++) {
        i18n.tc('plural_arg', i % 5, args);
      }
      stopNew.stop();

      // Baseline
      final stopOld = Stopwatch()..start();
      for (int i = 0; i < 10000; i++) {
        baseline.tc('plural_arg', i % 5, args);
      }
      stopOld.stop();

      final ratio = stopOld.elapsedMilliseconds / stopNew.elapsedMilliseconds;
      print('tc() plural x10000:');
      print('  New:      ${stopNew.elapsedMilliseconds}ms');
      print('  Baseline: ${stopOld.elapsedMilliseconds}ms');
      print('  Speedup:  ${ratio.toStringAsFixed(2)}x');
    });

    test('te() with 1 rich arg - comparison', () async {
      clearTemplateCache();

      final richSpan = TextSpan(text: 'here');
      final richArgs = {'link': richSpan};

      // New implementation
      final stopNew = Stopwatch()..start();
      for (int i = 0; i < 1000; i++) {
        i18n.te('rich_single', richArgs: richArgs);
      }
      stopNew.stop();

      // Baseline
      final stopOld = Stopwatch()..start();
      for (int i = 0; i < 1000; i++) {
        baseline.te('rich_single', richArgs: richArgs);
      }
      stopOld.stop();

      final ratio = stopOld.elapsedMilliseconds / stopNew.elapsedMilliseconds;
      print('te() with 1 rich arg x1000:');
      print('  New:      ${stopNew.elapsedMilliseconds}ms');
      print('  Baseline: ${stopOld.elapsedMilliseconds}ms');
      print('  Speedup:  ${ratio.toStringAsFixed(2)}x');
    });

    test('te() with 5 rich args - comparison', () async {
      clearTemplateCache();

      final richArgs = {
        'a': TextSpan(text: 'link1'),
        'b': TextSpan(text: 'link2'),
        'c': TextSpan(text: 'link3'),
        'd': TextSpan(text: 'link4'),
        'e': TextSpan(text: 'link5'),
      };

      // New implementation
      final stopNew = Stopwatch()..start();
      for (int i = 0; i < 1000; i++) {
        i18n.te('rich_multiple', richArgs: richArgs);
      }
      stopNew.stop();

      // Baseline
      final stopOld = Stopwatch()..start();
      for (int i = 0; i < 1000; i++) {
        baseline.te('rich_multiple', richArgs: richArgs);
      }
      stopOld.stop();

      final ratio = stopOld.elapsedMilliseconds / stopNew.elapsedMilliseconds;
      print('te() with 5 rich args x1000:');
      print('  New:      ${stopNew.elapsedMilliseconds}ms');
      print('  Baseline: ${stopOld.elapsedMilliseconds}ms');
      print('  Speedup:  ${ratio.toStringAsFixed(2)}x');
    });

    test('load() - comparison', () async {
      final language = AvailableLanguage(
        id: '1',
        code: 'en',
        name: 'English',
        messages: testMessages,
      );

      // New implementation
      final stopNew = Stopwatch()..start();
      for (int i = 0; i < 100; i++) {
        final tempI18n = LayrzAppLocalizations(
          languages: [language],
          currentLocale: const Locale('en'),
          fallbackLocale: const Locale('en'),
        );
        await tempI18n.load();
      }
      stopNew.stop();

      print('load() x100:');
      print('  New:      ${stopNew.elapsedMilliseconds}ms');
    });

    test('Benchmark Summary Table', () {
      print('\n========== BENCHMARK SUMMARY ==========');
      print('Summary of performance metrics:');
      print('- All timings in milliseconds');
      print('- Speedup ratio = Baseline time / New time');
      print('- Values > 1.0x mean new implementation is faster');
      print('========================================\n');
    });
  });
}
