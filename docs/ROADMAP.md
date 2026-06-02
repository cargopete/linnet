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
  override, week-by-week fetal milestones, explicit "gave birth" / "loss" states,
  and the late-pregnancy tools: **kick counter** (ACOG count-to-10 + personal
  baseline), **contraction timer** (start-to-start frequency, "511"-style call
  banner, copyable summary), **appointment/scan log** (standard schedule
  quick-adds), and **edit dating after start**. *Follow-ups:* see the pregnancy
  feature map below.
- **HealthKit** ✅ — manual import/export of **menstrual flow** via the `health`
  package (v13), with a pure tested `FlowIntensity ↔ MenstrualFlow` mapping, the
  HealthKit entitlement and `NSHealth*UsageDescription` strings wired in. Data
  stays on-device and is never used for advertising (Guideline 5.1.3). *Follow-ups:*
  the `health` plugin exposes no `basalBodyTemperature`/`sexualActivity`/
  `ovulationTestResult` on iOS, so those categories await a native bridge or a
  newer plugin; add background observer queries and an auto-sync toggle.
- **Onboarding + mode-switching** ✅ — first-run flow (privacy welcome, gated
  medical disclaimer, tracking-goal choice). The goal (avoid / conceive / general
  health / perimenopause) reframes the forecast: "best days to try" vs
  "higher-risk days", a stronger not-contraception caution when avoiding, and a
  symptom-focused note in perimenopause. Goal is changeable in Settings.
- ✅ **Perimenopause views** — a symptom-focused home that replaces cycle-day and
  predictions with "days since last period" and on-device symptom insights
  (ranked frequencies over 90 days), plus perimenopause symptoms (hot flashes,
  night sweats, mood swings, joint aches). Pure/tested insights engine.
- Local notifications (`flutter_local_notifications`) with non-descriptive content
  ("Time to log", never reproductive details).
- Duress/decoy PIN (à la Euki).
- Golden tests (Alchemist) and broader widget coverage.

## Stage 3 — Optional zero-knowledge backup ✅ (file-based)

- ✅ Client-side encryption: a random backup key encrypts the payload (AES-GCM-256),
  wrapped by an **Argon2id**-derived KEK from the user's passphrase.
- ✅ A **recovery key** that opens the backup without the passphrase, shown once
  with a blunt "lose both = unrecoverable" warning.
- ✅ Whole-database export/import in a single transaction; the encrypted file is
  written to the app's Documents folder (visible in Files) and can be copied out.
- ✅ **Off by default, opt-in**, no account, **no server** — true to the no-network
  promise. We deliberately did *not* build a cloud ciphertext store / LWW sync;
  the user owns the file. *Follow-ups (only if users ask):* a real file
  picker/share sheet, and — if cloud sync is ever genuinely wanted — an opt-in
  dumb ciphertext store with the same client-side crypto.

## Pregnancy experience — feature map (from the "Bairn" research)

What we already have vs. what's worth adding. ✅ shipped · ◐ partial · ⬜ to add.

**Dating & week-by-week core**
- ✅ LMP→EDD/gestational-age engine (Naegele + cycle adj, ultrasound precedence,
  clinician override), trimester, days-to-go, editable after start.
- ✅ Week-by-week sizes from a real per-week **length (mm) + weight (g) dataset**
  (Hadlock/Perinatology-style, weeks 5–40) with the **CRL→crown-heel switch
  disclosed**, plus the development note.
- ✅ **User-selectable comparison themes** computed from real measurements
  (classic / toys / sports / a **bird signature set** — week ~13 is literally "a
  linnet"). Switchable inline any week; choice persisted. *Follow-ups:* more
  themes (sea creatures, gaming, geeky), per-week illustrations, shareable cards.
- ⬜ Shareable, locally-rendered weekly/milestone cards (privacy-safe by default).

**Late-pregnancy toolkit**
- ✅ Kick counter (count-to-10, personal baseline).
- ✅ Contraction timer (start-to-start, call-pattern banner, copy summary).
- ✅ Appointments & scans with standard-schedule quick-adds.
- ⬜ Editable provider "go-to-hospital" rule; per-contraction intensity tags;
  keep-screen-on + dark "labor mode"; Apple Watch / Live Activity.
- ⬜ "Questions for next appointment" running list.

**Health tracking**
- ◐ Symptom logging exists for cycles; pregnancy-aware symptom suggestions +
  gentle on-device trend insights + soft "consider calling your provider" nudges
  for red-flag combinations ⬜.
- ✅ **Gestational-diabetes glucose log** — meal-tagged readings, typical
  provider-set targets with soft in/out-of-range flags, mg/dL ↔ mmol/L, 7-day
  average + % in range, copyable OB export. Pure/tested unit conversion + stats.
  *Follow-ups:* charts, insulin-dose trends, surface outside pregnancy mode.
- ⬜ Weight (non-judgmental range context), blood pressure,
  medication/supplement reminders, hydration, mood check-in (EPDS-style).

**Emotional safety & inclusivity (the headline market gap)**
- ✅ **Loss reflection mode** — recording a loss opens a calm reflection space
  instead of dumping back to cycle tracking: nothing is wiped, no baby reminders
  (there are none to fire), it never auto-switches to TTC/cycle content, the user
  can keep a memorial name and note, and it is only left when they explicitly
  choose "I am ready". A bootstrap seed prevents any flash of cycle content on
  launch. *Follow-ups:* a distinct lighter "pause" (non-loss), grief-resource
  links per region, and a pregnancy-history/memories view.
- ⬜ Inclusive language setting (gendered / neutral / custom), optional/non-binary
  baby-sex framing, neutral partner/support-person role.
- ⬜ Calm, low-density content that "ends each week on warmth"; avoid anxiety-fuel.

**Bonding & memory-keeping**
- ✅ **Firsts + letters** — a chronological memories timeline (one-tap "first"
  suggestions, letters to the baby) with a pure, tested keepsake compiler and a
  copyable keepsake.
- ✅ **Keepsake PDF** — a warm, on-device PDF of the journey (the bundled font is
  embedded for full Unicode), saved to Documents.
- ✅ **Encrypted photo gallery** — ultrasound/keepsake photos stored as BLOBs in
  the encrypted database (encrypted at rest, never uploaded), added from the photo
  library. *Note:* photos are deliberately excluded from the JSON backup (size).
  *Follow-ups:* bump-photo journal + timelapse, weekly one-line prompt.

**Logistics**
- ⬜ Birth-plan builder, hospital-bag checklist, **postpartum / "fourth trimester"**
  section (almost every app abandons the user at birth).

**Platform touches**
- ⬜ Home-screen widgets ("this week" size, countdown, next appointment), Siri
  shortcut ("log a kick"), notifications (opt-in, non-descriptive, pausable),
  Apple Watch companion, encrypted export/import for device moves.

These slot into Stages 2–3; the loss/pause reflection mode, themed size
comparisons, and the glucose module are the highest-value next picks.

## Thresholds that change the plan

- Contraception/pregnancy-prevention claims → FDA clearance + EU MDR Class IIb +
  clinical validation. **Default: don't.**
- EU users → GDPR Article 9 explicit consent and DPA readiness.
- Any analytics/third-party SDK → likely a covered "vendor of personal health
  records" under the FTC HBNR; update privacy labels. **Prefer zero SDKs.**
