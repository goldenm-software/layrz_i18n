CHMOD_CMD = chmod +x .githooks/pre-commit
ifeq ($(OS),Windows_NT)
    CHMOD_CMD = echo "Skipping chmod on Windows"
endif

.PHONY: freezed
freezed:
	dart run build_runner build

.PHONY: frizalo
frizalo: freezed

.PHONY: freezed-forced
freezed-forced:
	dart run build_runner build

.PHONY: install-hooks
install-hooks:
	@echo "Installing git hooks from .githooks directory..."
	@$(CHMOD_CMD)
	@git config core.hooksPath .githooks

.PHONY: checks
checks:
	@echo "Running CI checks..."
	@echo ""
	@echo "1. flutter analyze (lib/)..."
	@flutter analyze lib/ || exit 1
	@echo "   ✓ lib/ is clean"
	@echo ""
	@echo "2. flutter analyze (example/)..."
	@flutter analyze example/ || exit 1
	@echo "   ✓ example/ is clean"
	@echo ""
	@echo "3. Material/Cupertino guard..."
	@if grep -rq "package:flutter/material\|package:flutter/cupertino" lib/; then \
		echo "   ❌ Material or Cupertino imports found in lib/"; exit 1; \
	else \
		echo "   ✓ No Material or Cupertino imports in lib/"; \
	fi
	@echo ""
	@echo "4. Running tests with coverage..."
	@flutter test --coverage > /dev/null 2>&1 || { echo "   ❌ Tests failed"; exit 1; }
	@echo "   ✓ All tests passed"
	@echo ""
	@echo "5. Coverage floor (90%)..."
	@dart run tool/strip_ignored_coverage.dart coverage/lcov.info
	@PERCENTAGE=$$(awk -F'[:,]' '/^DA:/ {t++; if ($$3 != 0) h++} END {printf "%.2f", h*100/t}' coverage/lcov.info); \
	echo "   Coverage: $$PERCENTAGE%"; \
	if [ "$$(echo "$$PERCENTAGE < 90" | bc)" -eq 1 ]; then \
		echo "   ❌ Coverage is below the 90% floor!"; exit 1; \
	else \
		echo "   ✓ Coverage meets the 90% floor"; \
	fi
	@echo ""
	@echo "All checks passed ✓"

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
	@echo "  install-hooks - Install git hooks from .githooks directory"
	@echo "  checks - Run all CI checks (analyze, test, guards, coverage floor)"
	@echo "  lint - Run analyzer and formatter"
	@echo "  test - Run tests"
	@echo "  coverage - Run tests with coverage"
	@echo "  bench - Run benchmarks"
	@echo "  help - Show this help"
