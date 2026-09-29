# FraudRoko Play Store Production Release Checklist

This checklist is intentionally strict. A source tree is not considered production-ready until the code checks below and the Google/Firebase account checks are both complete.

## Source-level changes completed in this release candidate

- Premium entitlement is **not** granted from a SharedPreferences/local boolean.
- Successful Premium purchase/restore is sent to `verifyGooglePlaySubscription` for Google Play Developer API verification.
- Premium scan access reads the verified Firestore entitlement.
- Expired/non-active Premium entitlements do not unlock Premium.
- The app uses a local two-free-scan-per-installation model; uninstall/reinstall resets the local counter by design.
- Account deletion removes the user's own Premium and course entitlement records before Firebase Auth deletion.
- Firestore rules allow users to delete only their own entitlement records; they cannot create/update Premium entitlements.

## Required account-side steps

1. Google Play Console: create/activate `fraudroko_premium_monthly` and `fraudroko_premium_yearly` subscriptions and base plans.
2. Google Play Console: set India pricing to ₹99/month and ₹999/year.
3. Google Play Console: configure Play App Signing/release signing and package `com.fraudroko.fraudroko_app`.
4. Google Play Console: add license testers and publish an internal/closed testing release.
5. Google Cloud/Firebase: enable Google Play Developer API for the Functions runtime project.
6. Google Play Console: grant the Firebase Functions runtime service account the required Play Developer API access.
7. Google Cloud: create the `google-play-rtdn` Pub/Sub topic.
8. Google Play Console: enable Real-time Developer Notifications for the app and point them to that topic.
9. Firebase: deploy the Functions in `functions/`.
10. Test a real license-tester purchase, restore, renewal/grace/expiry lifecycle, and verify the Firestore entitlement changes.
11. Play Console: complete Data Safety, Account Deletion, App Content, Store Listing, and Permissions Declaration forms.
12. Because this app requests `QUERY_ALL_PACKAGES`, submit the required Permissions Declaration and explain that broad app visibility is required for the core phone-security scan's installed-app inventory analysis.
13. Add the account-specific Android Developer Verification registration file `android/app/src/main/assets/adi-registration.properties` locally before the final signed APK/AAB build. Do not commit or share the account-specific token in a public repository.

## Final release rule

Do not call the app production-ready until the account-side purchase verification and lifecycle test has passed. Source code alone cannot perform the Google Play/Firebase configuration steps above.
