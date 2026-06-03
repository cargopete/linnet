# Linnet 🐦

A **privacy-first, local-first** period & pregnancy tracker for iOS, built with Flutter.

Your data is encrypted on your device with AES-256. There is no account, no
server of ours, no analytics, and no third-party SDKs. Nothing leaves the device
unless *you* turn on an optional backup — and those are **end-to-end encrypted**,
so even iCloud only ever holds ciphertext it cannot read. The privacy design *is*
the product.

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
| **Cycle phases** (which phase you're in today + what's happening, on the period home) | ✅ |
| **Symptom patterns** (on-device symptom↔phase correlations from your own logs) | ✅ |
| Calendar with flow/period/fertile markers | ✅ |
| Biometric app-lock (Face ID / passcode) | ✅ |
| DB excluded from iCloud/iTunes backup | ✅ |
| Medical disclaimer, no contraception claims | ✅ |
| **Pregnancy mode** (Naegele's-rule EDD + ultrasound dating, week-by-week, birth/loss states) | ✅ |
| **Onboarding + goal-based mode-switching** (avoid / conceive / health / perimenopause) | ✅ |
| **HealthKit sync** (menstrual flow import/export, manual, on-device) | ✅ |
| **Pregnancy tools** (kick counter, contraction timer, appointments, edit dating) | ✅ |
| **Loss reflection mode** (no wipe, no auto-switch, memorialise, leave only when ready) | ✅ |
| **Week-by-week journey** (swipe back/forth through weeks: a code-drawn fetal silhouette that morphs by stage + bundled offline OpenMoji "as big as" illustrations, real cm/g dataset, switchable themes incl. a bird set) | ✅ |
| **Glucose log** (gestational diabetes: meal-tagged, typical targets, mg/dL ↔ mmol/L, OB export) | ✅ |
| **Bonding & memories** (firsts + letters timeline, copyable keepsake, **PDF export**, **encrypted photo gallery**) | ✅ |
| **Encrypted backup** (opt-in, zero-knowledge: Argon2id + AES-GCM, forced recovery key — a file you own **or** auto-backup to your own iCloud, recover on a new phone via Apple ID) | ✅ |
| **Perimenopause views** (symptom-focused home + on-device symptom insights) | ✅ |
| **Reminders** (opt-in daily local notifications, non-descriptive text, pausable) | ✅ |
| **Medications** (pills & supplements with opt-in daily reminders; names stay on-device, lock-screen text stays vague) | ✅ |
| **Baby mode** (Stage 1: child profiles — boy/girl with blue/pink theming across the whole app — + corrected age; frictionless feed/diaper/sleep logger; "time since last" home) | ✅ |
| **Coexisting tracks** (cycle, pregnancy and baby are not mutually exclusive — a Today switcher appears when more than one is active, so you track whatever fits your life at once) | ✅ |
| **Security hardening for 1.0** (thorough "delete everything" incl. key/iCloud; complete, non-destructive backups; exports via the share sheet — no browsable Documents; blurred app-switcher snapshot; local-only, expiring recovery-key copy) | ✅ |
| Tests + CI (generate, format, analyze, test) | ✅ |

The planned roadmap (Stages 1–3) is fully shipped, and a security & correctness
audit ahead of 1.0 has been actioned end to end (crypto, data-at-rest, file
exposure, privacy leakage). Remaining ideas — logistics toolkit (birth plan,
hospital bag, postpartum), a duress/decoy PIN, home-screen widgets and an Apple
Watch companion — are tracked in [`docs/ROADMAP.md`](docs/ROADMAP.md).

## Architecture

Feature-first clean architecture with Riverpod. See
[`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the full picture.

```
lib/src/
  common/         # crypto, database, routing, theme, util, preferences, providers
  features/
    app_lock/         application + presentation
    baby/             domain + data + application + presentation (child profiles, logger)
    backup/           domain (crypto) + data (file + iCloud) + presentation
    calendar/         presentation
    cycle_logging/    domain + data + application + presentation
    glucose/          domain + data + application + presentation
    health_sync/      domain + data + application + presentation (HealthKit)
    home/             presentation
    insights/         domain + application + presentation (perimenopause/symptoms)
    medications/      domain + data + application + presentation (med reminders)
    onboarding/       domain + presentation
    predictions/      domain (analyzer, predictor, phases, correlations) + presentation
    pregnancy/        domain + data + application + presentation
    reminders/        domain + data + application + presentation (local notifications)
    settings/         presentation
```

- **State management:** Riverpod 3
- **Storage:** Drift over SQLite3MultipleCiphers (AES-256), key in the iOS Keychain
- **Crypto key:** 256-bit DEK in `flutter_secure_storage`, device-only accessibility
- **Auth:** `local_auth` (Face ID / Touch ID / passcode)
- **Design language:** warm & wholesome — a deep-rose accent (the linnet's breast)
  on warm-stone neutrals, soft rounded shapes and cosy spacing. Typeface is Plus
  Jakarta Sans, **bundled offline** (no network fonts — the privacy promise extends
  to the font CDN). Theme lives in `lib/src/common/theme/app_theme.dart`.

## Getting started

Requires the Flutter SDK (stable, ≥ 3.44) and Xcode with the iOS platform
installed (`xcodebuild -downloadPlatform iOS` if Xcode reports
"iOS Platform Not Installed").

```bash
flutter pub get
dart run build_runner build      # generate Drift code (*.g.dart)
flutter test                     # 107 tests, all green
flutter run                      # on a simulator or device
```

The encrypted database relies on the `hooks: user_defines: sqlite3: source:
sqlite3mc` block in `pubspec.yaml`, which makes `package:sqlite3` bundle
SQLite3MultipleCiphers. At runtime we assert the `cipher` pragma exists and
refuse to open the database in cleartext otherwise.

## Tests

- Pure-domain unit tests: date utilities (incl. DST-safe day maths), cycle
  analyzer, cycle predictor, **cycle phases**, **symptom↔phase correlations**,
  pregnancy dating (Naegele + ultrasound precedence), contraction stats, glucose
  units/targets, keepsake builder, **baby age/corrected-age + time-since**,
  HealthKit flow mapping, reminder scheduling, and the **backup crypto**
  (Argon2id + AES-GCM, recovery key, stable-key round-trip).
- Repository round-trips against an in-memory database (daily logs, pregnancy,
  pregnancy tools, glucose, memories, photos, children/events, reminders) and the
  encrypted backup export→import across two databases.
- Widget tests for the goal-aware prediction card; a theme build/render test.

```bash
flutter test
```
