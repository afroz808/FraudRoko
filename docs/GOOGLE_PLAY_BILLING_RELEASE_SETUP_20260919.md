# FraudRoko Google Play Billing Release Setup

## App product IDs
- Monthly: `fraudroko_premium_monthly`
- Yearly: `fraudroko_premium_yearly`
- Package: `com.fraudroko.fraudroko_app`
- Intended India prices: ₹99/month and ₹999/year

## Important pricing rule
The app must not charge an amount from Firestore. Google Play is the payment authority for Premium. The Premium purchase screen already displays the price returned by Google Play `ProductDetails`.

The admin panel's `premium_config` is retained for existing UI/configuration and future offer management, but changing Firestore prices alone does NOT change the Google Play checkout price. Any seasonal Premium price must also be configured as a Google Play base-plan/offer (or synchronized through the Google Play Developer API).

## Backend verification
Cloud Function: `verifyGooglePlaySubscription`
- verifies the purchase token with Google Play Developer API
- checks the product ID against the two allowed Premium product IDs
- binds the token hash to the authenticated FraudRoko account
- grants Premium only when Google Play reports an active, non-expired state
- acknowledges verified active subscriptions

## Renewal/expiry synchronization
Cloud Function: `handleGooglePlaySubscriptionRtdn`
- Pub/Sub topic: `google-play-rtdn`
- refreshes entitlement after renewal, cancellation, grace period, recovery, pause, revoke, or expiry notifications
- stores only a SHA-256 purchase-token hash in Firestore

## External setup required in Google Cloud / Play Console
1. Enable the Google Play Developer API for the Google Cloud project used by the Firebase Functions runtime.
2. Grant the Firebase Functions runtime service account the required Play Console API access for this app.
3. Create Pub/Sub topic `google-play-rtdn` in the same Google Cloud project.
4. In Play Console, enable Real-time Developer Notifications for this app and select that Pub/Sub topic.
5. Create/activate the two Premium subscriptions and their base plans.
6. Set India prices to ₹99 and ₹999 for the corresponding base plans.
7. Add license testers and use an internal/closed testing track.
8. Deploy Firebase Functions and confirm the RTDN function receives a test notification.

## Learning payments

A complete migration of paid Learning content to Play Billing is a separate feature because each paid digital item needs an appropriate Play product/catalog design.

## Final release gate

The following items cannot be completed from source code alone and must be performed in the owner's Google/Firebase/Play Console accounts:

- Create/activate the two subscription products and base plans.
- Set India prices to ₹99/month and ₹999/year.
- Add the release signing key / Play App Signing configuration.
- Add license testers and publish an internal testing release.
- Enable Google Play Developer API access for the Firebase Functions runtime service account.
- Configure Pub/Sub topic `google-play-rtdn` and Play Console RTDN.
- Deploy Firebase Functions and verify the purchase-verification and RTDN functions in the deployed project.
- Complete Play Console Data Safety, Account Deletion, Permissions Declaration, Store Listing, and App Content forms using the released implementation.

Do not submit the app to production until the above account-side checks and a real license-tester purchase/restore/renewal test have passed.
