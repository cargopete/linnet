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

- **Pregnancy mode** ✅ — Naegele's-rule EDD with cycle-length adjustment,
  first-trimester ultrasound dating (ACOG >7-day precedence) and clinician-EDD
  override, week-by-week fetal milestones, and explicit "gave birth" / "loss"
  states. *Follow-ups:* edit dating after start, kick counts, contraction timer,
  appointment/scan log, pregnancy history view.
- **HealthKit** read/write for reproductive categories (`menstrualFlow`,
  `ovulationTestResult`, `cervicalMucusQuality`, `basalBodyTemperature`,
  `sexualActivity`, `pregnancy`, …) via the `health` package. Data kept on-device
  and excluded from backup; never used for advertising (Guideline 5.1.3).
- **Onboarding + mode-switching** ✅ — first-run flow (privacy welcome, gated
  medical disclaimer, tracking-goal choice). The goal (avoid / conceive / general
  health / perimenopause) reframes the forecast: "best days to try" vs
  "higher-risk days", a stronger not-contraception caution when avoiding, and a
  symptom-focused note in perimenopause. Goal is changeable in Settings.
- **Perimenopause-friendly** symptom-only tracking (no bleeding required) —
  copy/notes done; dedicated symptom-only views still to come.
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
