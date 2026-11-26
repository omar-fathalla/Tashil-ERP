# Tashil ERP

Offline-first inventory and POS for SUNMI V3 (Flutter, Drift, Riverpod,
Firebase). Talk to the product owner in Egyptian Arabic; code, comments,
commits and PRs stay in English.

## UI and Material Design 3
- All UI follows Material Design 3. Rules: `docs/design-system.md`.
- Every M3 item has a fixed ID in `docs/m3-catalog.md`. When someone sends
  an m3.material.io link or screenshot, review it with the steps in that
  file's "How to review an M3 page": match to IDs, update in place, add
  tests, docs and the playground, then report a table of results.
- Import `package:material_ui/material_ui.dart`, not `flutter/material`.
- Playground: `flutter run -t lib/main_playground.dart`.

## Checks before pushing
- `dart format lib test` (CI fails on unformatted files)
- `flutter analyze`
- `flutter test`

## Rules
- Money is integer piastres (`Money.format`). Western digits everywhere.
- Never commit secrets.
- Every PR and commit references its Linear issue (for example
  `Refs TAS2-52`).
