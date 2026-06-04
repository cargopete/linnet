# App Store submission kit

Everything needed to list Linnet on the App Store, written ahead of enrolment so
submission is a fill-in-the-blanks job once the **Apple Developer Program**
membership ($99/yr) is active. Items are flagged ⛔ (blocked on enrolment),
🟡 (do before submitting), or ✅ (ready / drafted here).

---

## Listing copy

**App name** (30 char max): `Linnet`
**Subtitle** (30 char max): `Private cycle & baby tracker`

**Promotional text** (170 char, updatable any time):
> Your cycle, pregnancy and baby — tracked privately on your device. No account,
> no servers, no tracking. Your data is encrypted and stays yours.

**Description** (4000 char):
> Linnet is a calm, private companion for your cycle, pregnancy and baby — built
> on one promise: your data never leaves your phone unless you choose.
>
> No account. No servers of ours. No analytics, no ads, no third-party trackers.
> Everything you log is encrypted on your device. The only thing that can ever
> leave is an optional backup — and those are end-to-end encrypted, so even
> iCloud only holds data it cannot read.
>
> ONE APP, MANY CHAPTERS
> • Cycle — log flow, symptoms, mood and temperature; see your phase, a
>   forecast with honest uncertainty, and patterns drawn only from your own data.
> • Pregnancy — due-date dating, a swipeable week-by-week journey, kick counter,
>   contraction timer, appointments, glucose log and a keepsake of your firsts.
> • Baby — feeds, diapers and sleep with a "time since last" home, built for
>   one-handed 3 a.m. use.
> These coexist: track whatever fits your life, all at once.
>
> PRIVACY IS THE PRODUCT
> • Encrypted on-device storage (AES-256).
> • Optional biometric app lock.
> • Optional, zero-knowledge encrypted backup to a file you own or your own
>   iCloud — recover on a new phone with your passphrase or recovery key.
> • Delete everything, completely, whenever you want.
>
> Linnet is a wellness tracker, not a medical device. It does not diagnose
> anything and must not be used as contraception or to prevent pregnancy.
> Predictions are estimates, not guarantees. For medical advice, see a clinician.

**Keywords** (100 char, comma-separated, no spaces):
`period,cycle,fertility,pregnancy,baby,ovulation,menstrual,private,tracker,feeding,offline`

**Support URL** 🟡: a simple page (the VPS can host it). Can point at the repo or a docs page.
**Marketing URL** (optional): —
**Privacy Policy URL** 🟡: host [`docs/PRIVACY.md`](PRIVACY.md) at a stable URL (required field).

---

## Category & rating

- **Primary category:** Health & Fitness
- **Secondary (optional):** Lifestyle
- **Age rating questionnaire** — expect **12+**. Answer honestly: the only
  notable item is *"Medical/Treatment Information"* → **Infrequent/Mild** (cycle
  & pregnancy info). Everything else (violence, gambling, etc.) → None.

---

## App Privacy ("nutrition label") — the easy, strong one

In App Store Connect → App Privacy, the answer is **"Data Not Collected."**

Justification (all true): there is no backend, no analytics SDK, no ads, no
third-party SDKs; all data is stored locally and encrypted; HealthKit access is
on-device and user-initiated (not "collected" by us); the optional iCloud backup
goes to the *user's own* iCloud as ciphertext. Nothing is linked to the user or
used for tracking.

- Data used to track you: **None**
- Data linked to you: **None**
- Data not linked to you: **None collected**

(If asked about HealthKit: declare the Health & Fitness data types read/written,
but it stays on device — Apple treats HealthKit separately and it is not
developer data collection.)

---

## Assets needed before submission

- **App icon** ✅ — a deep-rose linnet mark, painted in code
  (`lib/src/common/branding/linnet_mark.dart`), rendered to 1024 via
  `GEN_ICON=1 flutter test test/tools/generate_icon_test.dart`, and expanded to
  the full opaque iOS icon set with `dart run flutter_launcher_icons`.
- **Screenshots** 🟡 — required per device size (6.7"/6.9" iPhone, plus 13" iPad
  if we ship iPad). Capture from the simulator (we already do): onboarding,
  cycle home + phase, pregnancy week-journey, baby logger, encrypted-backup
  screen. 3–5 per size, optionally with captions.
- **Launch screen** — present (default); fine, can be polished later.

---

## Review notes (paste into "Notes for Reviewer")

> Linnet is fully local and works offline with no account — there is nothing to
> sign into. To see populated screens, the reviewer can simply log a few days,
> start a pregnancy, or add a baby from the home screen. Health data is optional
> and user-initiated. Linnet is a wellness tracker, not a medical device, and
> explicitly states it must not be used as contraception (in-app disclaimer +
> store description).

Watch-outs for review:
- **Guideline 5.1.1 (HealthKit/permissions):** usage strings are set in
  Info.plist and access is opt-in.
- **No account (5.1.1(v)):** account-free, so no "account deletion" requirement —
  but "Delete all data" exists and is thorough.
- **Medical claims (1.4.1 / 5.x):** keep all copy non-diagnostic, no contraception
  claims (already enforced in-app).

---

## Submission checklist

1. ⛔ Enrol in the Apple Developer Program ($99/yr).
2. ⛔ Create the App ID + app record in App Store Connect (bundle `com.linnet.app`).
3. ⛔ Enable capabilities on the App ID: HealthKit, iCloud (CloudDocuments).
   These are the entitlements stripped on the `sideload-free-signing` branch —
   ship from `main`, which keeps them.
4. 🟡 Real app icon + screenshots (above).
5. 🟡 Host the privacy policy + support URLs.
6. ⛔ Set up signing (distribution cert + App Store provisioning profile);
   `flutter build ipa`.
7. ⛔ Upload via Transporter / Xcode; test via **TestFlight** first.
8. 🟡 Fill App Privacy ("Data Not Collected"), category, age rating, review notes.
9. ⛔ Submit for review.

**Bottom line:** steps 4/5/8 are doable now; the rest unlock the moment the
membership is active.
