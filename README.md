# Linnet 🐦

A **privacy-first, local-first** period & pregnancy tracker for iOS, built with Flutter.

Your data is encrypted on your device with AES-256 and never leaves it. There is
no account, no server, no analytics, and no third-party SDKs. The privacy design
*is* the product.

> **Not a medical device.** Linnet is a wellness tracker. It does not diagnose
> anything and **must not be used as contraception or to prevent pregnancy**.
> Predictions are estimates with real uncertainty, not guarantees. For medical
> advice, consult a clinician.

## Why local-first

Post-*Dobbs*, reproductive-health data carries real legal jeopardy, and HIPAA
does not cover consumer tracking apps. The apps experts recommend (Euki, drip.,
Periodical) win precisely because they store data locally and track nothing.
Linnet follows that model: data minimisation, no trackers, backup off by default,
and easy complete deletion. (Local storage is not a panacea — device seizure and
forensic extraction remain risks — so we also encrypt at rest and offer a
biometric app-lock. See [`docs/PRIVACY.md`](docs/PRIVACY.md).)

## Status

| Area | State |
|------|-------|
| Encrypted local store (Drift + SQLite3MultipleCiphers, key in Keychain) | ✅ |
| Daily logging (flow, symptoms, mood, BBT, notes) | ✅ |
| Cycle detection + calendar/statistical prediction with **uncertainty ranges** | ✅ |
| Calendar with flow/period/fertile markers | ✅ |
| Biometric app-lock (Face ID / passcode) | ✅ |
| DB excluded from iCloud/iTunes backup | ✅ |
| Medical disclaimer, no contraception claims | ✅ |
| **Pregnancy mode** (Naegele's-rule EDD + ultrasound dating, week-by-week, birth/loss states) | ✅ |
| **Onboarding + goal-based mode-switching** (avoid / conceive / health / perimenopause) | ✅ |
| **HealthKit sync** (menstrual flow import/export, manual, on-device) | ✅ |
| **Pregnancy tools** (kick counter, contraction timer, appointments, edit dating) | ✅ |
| **Loss reflection mode** (no wipe, no auto-switch, memorialise, leave only when ready) | ✅ |
| **Themed week-by-week sizes** (real cm/g dataset, switchable themes incl. a bird set) | ✅ |
| Tests + CI (generate, format, analyze, test) | ✅ |

Planned next: a loss/pause **reflection mode**, themed week-by-week size
comparisons (incl. a bird set) from a real measurement dataset, a
gestational-diabetes glucose module, perimenopause-specific views, and an
*opt-in* zero-knowledge encrypted backup. The full pregnancy feature map and
stage plan live in [`docs/ROADMAP.md`](docs/ROADMAP.md).

## Architecture

Feature-first clean architecture with Riverpod. See
[`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the full picture.

```
lib/src/
  common/         # crypto, database, routing, theme, util, preferences, providers
  features/
    app_lock/         application + presentation
    calendar/         presentation
    cycle_logging/    domain + data + application + presentation
    health_sync/      domain + data + application + presentation (HealthKit)
    home/             presentation
    onboarding/       domain + presentation
    predictions/      domain (analyzer + predictor) + presentation
    pregnancy/        domain + data + application + presentation
    settings/         presentation
```

- **State management:** Riverpod 3
- **Storage:** Drift over SQLite3MultipleCiphers (AES-256), key in the iOS Keychain
- **Crypto key:** 256-bit DEK in `flutter_secure_storage`, device-only accessibility
- **Auth:** `local_auth` (Face ID / Touch ID / passcode)

## Getting started

Requires the Flutter SDK (stable, ≥ 3.44) and Xcode with the iOS platform
installed (`xcodebuild -downloadPlatform iOS` if Xcode reports
"iOS Platform Not Installed").

```bash
flutter pub get
dart run build_runner build      # generate Drift code (*.g.dart)
flutter test                     # 41 tests, all green
flutter run                      # on a simulator or device
```

The encrypted database relies on the `hooks: user_defines: sqlite3: source:
sqlite3mc` block in `pubspec.yaml`, which makes `package:sqlite3` bundle
SQLite3MultipleCiphers. At runtime we assert the `cipher` pragma exists and
refuse to open the database in cleartext otherwise.

## Tests

- Pure-domain unit tests: date utilities (incl. DST-safe day maths), cycle
  analyzer, cycle predictor, pregnancy dating (Naegele + ultrasound precedence),
  contraction stats, tracking-goal preferences, HealthKit flow mapping.
- Repository round-trips against an in-memory database (daily logs, pregnancy,
  pregnancy tools).
- Widget tests for the goal-aware prediction card.

```bash
flutter test
```
