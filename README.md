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

## Status — Stage 1 MVP

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
| Tests + CI (generate, format, analyze, test) | ✅ |

Planned (Stage 2+): HealthKit reproductive categories, perimenopause
symptom-only tracking, inclusive onboarding, and an *opt-in* zero-knowledge
encrypted backup. See [`docs/ROADMAP.md`](docs/ROADMAP.md).

## Architecture

Feature-first clean architecture with Riverpod. See
[`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the full picture.

```
lib/src/
  common/         # crypto, database, routing, theme, util, providers
  features/
    app_lock/         application + presentation
    calendar/         presentation
    cycle_logging/    domain + data + application + presentation
    home/             presentation
    predictions/      domain (analyzer + predictor) + presentation
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
flutter test                     # 16 tests, all green
flutter run                      # on a simulator or device
```

The encrypted database relies on the `hooks: user_defines: sqlite3: source:
sqlite3mc` block in `pubspec.yaml`, which makes `package:sqlite3` bundle
SQLite3MultipleCiphers. At runtime we assert the `cipher` pragma exists and
refuse to open the database in cleartext otherwise.

## Tests

- Pure-domain unit tests: date utilities, cycle analyzer, cycle predictor.
- Repository round-trip against an in-memory database.
- Widget test for the prediction card.

```bash
flutter test
```
