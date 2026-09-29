# FraudRoko — Play Store Compliance Master

## 1. Purpose

FraudRoko is a Cyber Security Assistant designed to help users understand
online fraud, scams, and device security risks.

FraudRoko is NOT an antivirus.

## 2. Compliance Rule

Every permission, API, data flow, and user-facing security feature must:

- have a real current use;
- be necessary for the implemented functionality;
- be disclosed to the user where required;
- comply with Google Play policies;
- have supporting code evidence;
- have accurate Play Console declarations where required;
- avoid misleading security claims;
- avoid fake scans or fake security results.

## 3. High-Risk Permission Audit

### QUERY_ALL_PACKAGES

Status: KEEP FOR AUDIT — FINAL DECISION PENDING

Current purpose:
Installed-app security analysis.

Code evidence:
InstalledAppsProvider scans installed packages and analyzes application
metadata, permissions, installer/source information, and hidden-app status.

Play policy question:
Can broad package visibility be justified as core user-facing functionality,
and can a less broad visibility method provide the same functionality?

Required:
- policy justification
- declaration strategy
- reviewer instructions
- privacy/data disclosure

### MANAGE_EXTERNAL_STORAGE

Status: INVESTIGATE — DO NOT REMOVE YET

Current evidence:
APK scanning currently uses the app-specific external files directory.
APK folder selection uses Android Storage Access Framework.

Play policy question:
Does the implemented feature genuinely require broad shared-storage access?

Required:
- verify complete implementation
- verify whether broad access is actually required
- determine KEEP / REPLACE / REMOVE
- if kept, prepare Permissions Declaration justification

## 4. Account Deletion

Status: REQUIRED — IMPLEMENTATION AUDIT PENDING

FraudRoko allows account creation.

Required:
- in-app account deletion
- external web deletion resource
- backend deletion of associated user data
- documented legitimate retention where applicable
- Privacy Policy disclosure
- Play Console Data Safety deletion answers

## 5. Data Safety

Status: AUDIT PENDING

Must audit:
- Firebase Authentication
- Firebase Analytics
- Firestore
- Firebase Cloud Messaging
- payment backend
- premium entitlements
- cyber news
- security scan data
- reports
- learning/course data
- third-party SDKs

## 6. Privacy Policy

Status: AUDIT PENDING

Must accurately document:
- data accessed
- data collected
- data processed on-device
- data stored remotely
- data sharing
- purposes
- retention
- deletion
- account deletion
- third-party services
- security practices

## 7. Reviewer Access

Status: PENDING

Prepare:
- demo account
- login instructions
- permission testing instructions
- security scan testing instructions
- premium testing instructions
- reviewer notes for restricted functionality

## 8. Store Listing Claims

Status: AUDIT PENDING

Rules:
- no antivirus claim
- no false malware detection claim
- no fake protection claim
- no unsupported 24/7 protection claim
- every security capability advertised must exist in the released build

## 9. Final Decision Rule

Do not remove or retain a sensitive permission based only on assumption.

Decision must be based on:

Code evidence
+
Actual feature requirement
+
Google Play policy
+
Privacy/data disclosure
+
Play Console declaration requirements

### Backend production dependency

Premium purchase verification requires the deployed `verifyGooglePlaySubscription` Cloud Function. The client must not use a local entitlement flag as proof of payment.

The current Functions package targets Node.js 22 for a supported Firebase runtime. Cloud Functions deployment requires the Firebase project billing setup required by Google/Firebase.

## 10. Final Submission Gate

FraudRoko must not be submitted until:

- code audit complete
- permissions audited
- sensitive APIs audited
- Data Safety verified
- Privacy Policy verified
- account deletion verified
- reviewer access verified
- store listing claims verified
- release build tested
- Play Console declarations prepared


## 2026-09-16 Permission Cleanup
- MANAGE_EXTERNAL_STORAGE / All Files Access request flow removed from the application.
- The APK archive scan flow that required broad storage access was removed from the phone security scan path.
- QUERY_ALL_PACKAGES remains only for the installed-app security scan and must be declared/justified in Play Console based on actual core functionality.
- Release manifest explicitly declares INTERNET because Firebase and online FraudRoko features require network access.


### QUERY_ALL_PACKAGES reviewer explanation
FraudRoko's core Phone Security Scan evaluates the applications installed on the user's Android device as one of its security checks. The app uses package visibility to enumerate installed applications, classify them as system/user/hidden and analyze requested permissions and installation-source signals that are used by the local security report. The result is presented to the user as part of the Phone Security Scan. Broad package visibility is not used for advertising, profiling, sale of app-inventory data, or unrelated analytics. The app does not request MANAGE_EXTERNAL_STORAGE for this functionality.

User-facing disclosure shown on the scan screen: 
- English: FraudRoko checks installed apps only to perform the phone security scan.
- Hindi: FraudRoko installed apps को केवल फोन की security जांच के लिए देखता है।
- Marathi: FraudRoko installed apps फक्त फोनची security तपासण्यासाठी पाहतो.

Declaration note: retain QUERY_ALL_PACKAGES only while this installed-app security scan remains a genuine core functionality and the Play Console declaration accurately reflects the released implementation.
