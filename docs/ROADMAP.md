# Roadmap

## Stage 1 — MVP (local-only) ✅ done

- Feature-first Flutter project with Riverpod.
- Drift + SQLite3MultipleCiphers; 256-bit DEK in the Keychain; DB excluded from
  backup; biometric app-lock.
- Calendar-based prediction with explicit uncertainty ranges; medical disclaimer;
  no contraception claims.
- Daily logging, calendar, settings, data deletion.
- Tests + CI.

## Stage 2 — Differentiators

- **HealthKit** read/write for reproductive categories (`menstrualFlow`,
  `ovulationTestResult`, `cervicalMucusQuality`, `basalBodyTemperature`,
  `sexualActivity`, `pregnancy`, …) via the `health` package. Data kept on-device
  and excluded from backup; never used for advertising (Guideline 5.1.3).
- **Pregnancy mode:** Naegele's-rule EDD with cycle-length adjustment, week-by-week
  tracking, and explicit "gave birth" / "pregnancy loss" states.
- **Perimenopause-friendly** symptom-only tracking (no bleeding required).
- **Inclusive onboarding** that asks the tracking goal and adapts UI/copy.
- Local notifications (`flutter_local_notifications`) with non-descriptive content
  ("Time to log", never reproductive details).
- Duress/decoy PIN (à la Euki).
- Golden tests (Alchemist) and broader widget coverage.

## Stage 3 — Optional zero-knowledge backup (only if users ask)

- Client-side E2EE (XChaCha20-Poly1305), Argon2id-derived keys.
- A forced, acknowledged **recovery key** ("lost key = lost data").
- A dumb ciphertext store (custom REST / Supabase as opaque blob storage).
- Last-write-wins sync. **Off by default, opt-in.**

## Thresholds that change the plan

- Contraception/pregnancy-prevention claims → FDA clearance + EU MDR Class IIb +
  clinical validation. **Default: don't.**
- EU users → GDPR Article 9 explicit consent and DPA readiness.
- Any analytics/third-party SDK → likely a covered "vendor of personal health
  records" under the FTC HBNR; update privacy labels. **Prefer zero SDKs.**
