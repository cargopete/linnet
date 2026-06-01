# Privacy & threat model

Linnet's guiding principle: **the safest data is the data that never leaves your
device, and the data that isn't collected at all.**

## What we do

- **Local-only by default.** No account, no server, no network calls for your
  health data. Nothing is uploaded.
- **Encrypted at rest.** All data is stored in a SQLite database encrypted with
  AES-256 (SQLite3MultipleCiphers). The 256-bit key lives in the iOS Keychain,
  pinned to this device (`first_unlock_this_device`) and excluded from backups.
- **No trackers, no analytics, no third-party SDKs.** Flutter telemetry is
  disabled in development. Adding any analytics SDK would likely make us a
  "vendor of personal health records" under the FTC Health Breach Notification
  Rule — so we don't.
- **Biometric app-lock.** Optional Face ID / Touch ID / passcode gate that hides
  all content (including the app-switcher snapshot) when locked or backgrounded.
- **Backup exclusion.** The database directory is flagged
  `NSURLIsExcludedFromBackupKey` so it stays out of iCloud and encrypted Finder
  backups. (Apple notes this flag is advisory, not a guarantee — hence defence in
  depth, not a single lock.)
- **Easy, complete deletion.** "Delete all data" wipes every record.

## What local storage does *not* protect against

We are honest about the limits:

- **Device seizure + forensic extraction.** Tools like Cellebrite can extract app
  data from an unlocked or weakly-protected device. Mitigations: a strong device
  passcode, full-device encryption, and the in-app biometric lock.
- **Border searches**, where devices may be searched without a warrant.
- **Other digital traces.** Prosecutions to date have relied on messages and
  search history, not the period app itself. Linnet cannot protect data that
  lives elsewhere.

The strongest protections remain: a strong passcode, cloud backups off, data
minimisation, and deleting what you no longer need.

## Regulatory posture

- **Not a medical device.** Predictions are informational; we make no
  contraceptive or pregnancy-prevention claim, which keeps Linnet a wellness app
  rather than an FDA-cleared device / EU MDR Class IIb device.
- **Apple App Store.** Data processed *only on device* is not "collected" and
  need not be declared — the goal is a "Data Not Collected" privacy label. A
  plain-language privacy policy and an in-app medical disclaimer are required and
  present.
- **HealthKit (Stage 2).** Any HealthKit-derived data will be kept on-device and
  excluded from backup, never used for advertising, per Guideline 5.1.3.

> This document is engineering and product guidance, **not legal advice**.
> Consult a privacy/health-law attorney before any public release handling
> reproductive-health data.
