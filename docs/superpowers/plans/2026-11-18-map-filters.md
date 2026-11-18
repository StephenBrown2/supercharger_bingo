# Map Filters Implementation Plan

**Goal:** Align filter terminology and add charger types, combining missing and unknown types as approved.

**Architecture:** Preserve status queries. Cache five upstream stall counts, then apply a type predicate to their results. Refresh cached regions after migration.

**Tech stack:** Dart, Flutter, Drift.

**Spec:** [Approved design](../specs/2026-11-18-map-filters-design.md), amended to combine Unknown and Not specified.

## Constraints

No new dependencies, no settings persistence, no changes to visit data or status matching.

## Review focus

Mixed types, empty counts, `other` counts, upgraded caches, and combined status/type selection must work.

## Tasks

- [x] Add regression tests for type parsing, matching, and cache migration; run them before implementation.
- [x] Add count columns and migration in database.dart, retain them in api_service.dart, regenerate database.g.dart, and verify tests.
- [x] Update map_screen.dart labels and type dropdown; test combined selection through actual map widgets.
- [x] Update filter documentation, run Flutter tests and analyzer, and review the diff.

Execution: native implementation in this session. Leave existing unrelated edits untouched. Commit and push the filter work and Android verification instructions, as requested.

Validation: `flutter test --reporter expanded` passed all 142 tests. `flutter analyze` reported no issues. Map selection tests exercise a 411 dp viewport with clustering both enabled and disabled. The physical Pixel 9 reinstall succeeded. Pixel 9 Android 17 emulator checks passed for carousel order, Visited, All and combined V3 filtering. Pixel 8a Android 17 emulator installation, first-run setup, initial map layout and regional site loading were verified; carousel interaction checks stopped after the device tool twice rejected gestures with `Gesture trajectory does not fit inside the viewport`. No live fork comparison was run.
