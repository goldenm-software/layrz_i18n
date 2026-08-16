.PHONY: freezed
freezed:
	dart run build_runner build

.PHONY: frizalo
frizalo: freezed

.PHONY: freezed-forced
freezed-forced:
	dart run build_runner build

.PHONY: lint
lint:
	flutter analyze
	dart format --line-length 120 --set-exit-if-changed lib/layrz_i18n.dart lib/src test

.PHONY: test
test:
	flutter test

.PHONY: coverage
coverage:
	flutter test --coverage
	dart run tool/strip_ignored_coverage.dart
	awk -F: '/^LH:/ {hit+=$$2} /^LF:/ {total+=$$2} END { if (total>0) printf "Coverage: %.2f%% (%d/%d lines)\n", hit*100/total, hit, total; else print "No coverage data" }' coverage/lcov.info

.PHONY: bench
bench:
	flutter test --tags benchmark

.PHONY: help
help:
	@echo "Available targets:"
	@echo "  freezed - Generate freezed code"
	@echo "  freezed-forced - Generate freezed code with conflict resolution"
	@echo "  lint - Run analyzer and formatter"
	@echo "  test - Run tests"
	@echo "  coverage - Run tests with coverage"
	@echo "  bench - Run benchmarks"
	@echo "  help - Show this help"
