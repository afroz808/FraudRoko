# FraudRoko — Final Release Candidate

This source preserves the existing FraudRoko login, security scan, reports, notification access, learning, and Premium work.

## Code-side release work completed in this candidate

- Flutter analyzer cleanup from the previous audit.
- Google Play Billing Premium flow retained.
- Premium products: `fraudroko_premium_monthly`, `fraudroko_premium_yearly`.
- Intended India prices: ₹99/month and ₹999/year.
- Google Play Billing remains the Premium purchase authority.
- Premium access in this zero-Blaze release is handled from Google Play purchase/restore status on the device; the app no longer depends on a Firebase Cloud Function for Premium activation.
- Two free phone-security scans are available per app installation; the third scan opens the Premium gate. Reinstalling the app starts a new two-scan installation allowance.
- Account deletion uses Firebase Authentication re-authentication followed by the supported client-side user deletion flow; no Cloud Function is required.
- The previous Cloud Functions source remains in the repository for future backend deployment, but this release does not require it.
- Public privacy-policy page added under `public/privacy-policy.html`.

## Required owner-side release work

These require access to the actual Google Play Console / Google Cloud / Firebase project and cannot be safely invented in source code:

1. Configure Google Play subscriptions and base plans at ₹99/month and ₹999/year.
2. Configure Play App Signing/release signing.
3. Add license testers and publish an internal testing build.
4. Add license testers and test Google Play purchase/restore behavior.
5. Complete Play Console Data Safety, Account Deletion, QUERY_ALL_PACKAGES Permissions Declaration, Store Listing, and App Content declarations.
6. Verify the public Privacy Policy and account-deletion URLs after Firebase Hosting deployment.

## Final local verification

```bash
flutter clean
flutter pub get
flutter analyze
flutter build appbundle --release
```

Expected analyzer result:

```text
No issues found!
```

Expected release artifact:

```text
build/app/outputs/bundle/release/app-release.aab
```

Do not treat a successful local AAB build as proof that Google Play Billing or Play Console configuration is complete. Those must be tested through Google Play internal/closed testing.
