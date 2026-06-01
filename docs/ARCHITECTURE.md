# Architecture

Linnet uses a **feature-first clean architecture** with Riverpod, the 2025–2026
community default for a scalable, testable Flutter project.

## Layers

Within each feature, code is grouped by responsibility:

- **`domain/`** — pure Dart entities and logic. No Flutter, no I/O. The cycle
  analyzer and predictor live here and are exhaustively unit-tested.
- **`data/`** — repositories that map between storage rows and domain objects.
- **`application/`** — Riverpod controllers/providers that hold UI state.
- **`presentation/`** — widgets and screens.

Shared infrastructure lives under `lib/src/common/` (crypto, database, routing,
theme, util, and the cross-feature `providers.dart`).

## Data flow

```
SQLite (encrypted)
   │  Drift
AppDatabase ──► DailyLogRepository ──► allLogsProvider (Stream)
                                          │
                                  CycleAnalyzer ──► cyclesProvider
                                          │
                                  CyclePredictor ──► predictionProvider
                                          │
                                    HomeScreen / CalendarScreen
```

Everything downstream of storage is derived and reactive: log a day, and the
cycle history and forecast recompute automatically.

## Storage & encryption

- **Drift** over **SQLite3MultipleCiphers** gives transparent AES-256 encryption.
  Selected via the `hooks: user_defines: sqlite3: source: sqlite3mc` build hook
  in `pubspec.yaml` (the modern replacement for the defunct
  `sqlcipher_flutter_libs`).
- A **256-bit DEK** is generated with `Random.secure()` on first run and stored
  in the iOS Keychain via `flutter_secure_storage` with
  `first_unlock_this_device` accessibility — device-only, excluded from backups.
- The key is applied as a **raw key** (`PRAGMA key = "x'…'"`), so no KDF is
  involved and all 256 bits of entropy are used directly.
- `connection.dart` asserts the `cipher` pragma at runtime and **refuses to open
  the database in cleartext** if the encrypted build is missing.
- The database lives in a dedicated `Application Support` subdirectory whose
  `NSURLIsExcludedFromBackupKey` flag is set (via a Swift method channel in
  `AppDelegate.swift`) to keep it out of iCloud/Finder backups.

## Prediction engine

`CyclePredictor` models cycle length as a distribution: it forecasts the next
start from the mean of recent cycles and reports a ± band sized from the sample
standard deviation. Irregular cyclers get wide bands and a low confidence — the
honest answer. Defaults are grounded in the literature (population mean ~29 days,
~13-day luteal phase, Wilcox 6-day fertile window). It makes **no contraception
claim** and never presents a single guaranteed day.

## State management

Riverpod 3. The database and Keychain handle are created during bootstrap in
`main.dart` (the only async-at-startup work) and injected via
`ProviderScope.overrides`, so the rest of the tree consumes them synchronously.
