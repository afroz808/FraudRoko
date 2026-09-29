const {setGlobalOptions} = require("firebase-functions");
const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {onMessagePublished} = require("firebase-functions/v2/pubsub");
const {getFirestore, FieldValue} = require("firebase-admin/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getAuth} = require("firebase-admin/auth");
const crypto = require("crypto");
const {google} = require("googleapis");

setGlobalOptions({maxInstances: 10});

initializeApp();

const db = getFirestore();

const PACKAGE_NAME = "com.fraudroko.fraudroko_app";

const ALLOWED_PRODUCTS = new Set([
  "fraudroko_premium_monthly",
  "fraudroko_premium_yearly",
]);

const ACTIVE_STATES = new Set([
  "SUBSCRIPTION_STATE_ACTIVE",
  "SUBSCRIPTION_STATE_IN_GRACE_PERIOD",
]);

/**
 * Creates an authenticated Google Play Developer API client.
 */
async function getPlayApi() {
  const auth = new google.auth.GoogleAuth({
    scopes: [
      "https://www.googleapis.com/auth/androidpublisher",
    ],
  });

  const client = await auth.getClient();

  return google.androidpublisher({
    version: "v3",
    auth: client,
  });
}


exports.getDashboardStats = onCall(
    async (request) => {
      if (!request.auth) {
        throw new HttpsError(
            "unauthenticated",
            "Login required.",
        );
      }

      const adminDoc = await db
          .collection("admins")
          .doc(request.auth.uid)
          .get();

      if (
        !adminDoc.exists ||
        adminDoc.data()?.enabled !== true ||
        adminDoc.data()?.role !== "owner"
      ) {
        throw new HttpsError(
            "permission-denied",
            "Owner access required.",
        );
      }

      try {
        let totalUsers = 0;
        let pageToken;

        do {
          const result = await getAuth().listUsers(1000, pageToken);
          totalUsers += result.users.length;
          pageToken = result.pageToken;
        } while (pageToken);

        const premiumSnapshot = await db
            .collection("premium_entitlements")
            .where("status", "==", "active")
            .get();

        return {
          totalUsers: totalUsers,
          premiumUsers: premiumSnapshot.size,
        };
      } catch (error) {
        console.error("Dashboard stats failed:", error);

        throw new HttpsError(
            "internal",
            "Dashboard statistics are temporarily unavailable.",
        );
      }
    },
);


/**
 * Keeps the server-side Premium entitlement synchronized with Google Play
 * subscription lifecycle changes (renewal, cancellation, expiry, grace period,
 * recovery, etc.). The RTDN contains only a change signal, so the current
 * subscription state is fetched from the Google Play Developer API.
 */
exports.handleGooglePlaySubscriptionRtdn = onMessagePublished(
    "google-play-rtdn",
    async (event) => {
      const messageId = event.id || event.data?.message?.messageId || "unknown";
      const payload = event.data?.message?.json;

      if (!payload || payload.packageName !== PACKAGE_NAME) {
        console.log("Ignoring unrelated Google Play RTDN", messageId);
        return;
      }

      const notification = payload.subscriptionNotification;
      if (!notification || typeof notification.purchaseToken !== "string") {
        // Test notifications and non-subscription notifications do not contain
        // a purchase token that can be used for entitlement synchronization.
        return;
      }

      const token = notification.purchaseToken;
      const purchaseTokenHash = crypto
          .createHash("sha256")
          .update(token, "utf8")
          .digest("hex");

      const tokenOwnerSnapshot = await db
          .collection("premium_entitlements")
          .where("purchaseTokenHash", "==", purchaseTokenHash)
          .limit(1)
          .get();

      if (tokenOwnerSnapshot.empty) {
        // App may not have completed the first client-side verification yet.
        // The normal purchase verification path will bind the token to the
        // account when that happens.
        console.log("RTDN token has no linked FraudRoko account", messageId);
        return;
      }

      const uid = tokenOwnerSnapshot.docs[0].id;
      const play = await getPlayApi();
      const response = await play.purchases.subscriptionsv2.get({
        packageName: PACKAGE_NAME,
        token: token,
      });

      const purchase = response.data || {};
      const lineItems = Array.isArray(purchase.lineItems) ?
        purchase.lineItems : [];

      const matchingItem = lineItems.find(
          (item) => ALLOWED_PRODUCTS.has(item.productId),
      );

      if (!matchingItem) {
        console.warn("RTDN purchase has no allowed Premium product", messageId);
        return;
      }

      const state = purchase.subscriptionState || "";
      const expiryTime = matchingItem.expiryTime || null;
      const expiryMs = expiryTime ? Date.parse(expiryTime) : 0;
      const isActive =
        ACTIVE_STATES.has(state) &&
        expiryMs > Date.now();

      const entitlementRef = db
          .collection("premium_entitlements")
          .doc(uid);

      await entitlementRef.set({
        status: isActive ? "active" : "free",
        productId: matchingItem.productId,
        subscriptionState: state,
        expiresAt: expiryTime,
        purchaseTokenHash: purchaseTokenHash,
        purchaseTokenVerified: true,
        lastRtdnMessageId: messageId,
        lastRtdnType: notification.notificationType || null,
        updatedAt: FieldValue.serverTimestamp(),
      }, {merge: true});

      // Acknowledge only after the subscription is PURCHASED/ACTIVE. Google
      // requires acknowledgement for completed subscription purchases.
      if (isActive && state === "SUBSCRIPTION_STATE_ACTIVE") {
        try {
          await play.purchases.subscriptions.acknowledge({
            packageName: PACKAGE_NAME,
            subscriptionId: matchingItem.productId,
            token: token,
            requestBody: {},
          });
        } catch (error) {
          console.error(
              "RTDN subscription acknowledgement failed:",
              (error && error.response && error.response.data) || error.message,
          );
        }
      }

      console.log("Google Play entitlement synchronized", {
        uid,
        productId: matchingItem.productId,
        state,
        isActive,
        messageId,
      });
    },
);

exports.verifyGooglePlaySubscription = onCall(
    async (request) => {
      if (!request.auth) {
        throw new HttpsError(
            "unauthenticated",
            "Login required.",
        );
      }

      const data = request.data || {};
      const token = data.purchaseToken;
      const requestedProductId = data.productId;

      if (typeof token !== "string" || token.length < 20) {
        throw new HttpsError(
            "invalid-argument",
            "Invalid purchase token.",
        );
      }

      if (
        typeof requestedProductId !== "string" ||
        !ALLOWED_PRODUCTS.has(requestedProductId)
      ) {
        throw new HttpsError(
            "invalid-argument",
            "Invalid Premium product.",
        );
      }

      let play;

      try {
        play = await getPlayApi();
      } catch (error) {
        console.error("Google Play auth failed:", error);
        throw new HttpsError(
            "internal",
            "Payment verification is temporarily unavailable.",
        );
      }

      let purchase;

      try {
        const response =
          await play.purchases.subscriptionsv2.get({
            packageName: PACKAGE_NAME,
            token: token,
          });

        purchase = response.data;
      } catch (error) {
        console.error(
            "Google Play verification failed:",
            (error && error.response && error.response.data) || error.message,
        );

        throw new HttpsError(
            "failed-precondition",
            "Purchase could not be verified.",
        );
      }

      const lineItems = Array.isArray(purchase.lineItems) ?
        purchase.lineItems :
        [];

      const matchingItem = lineItems.find(
          (item) => item.productId === requestedProductId,
      );

      if (!matchingItem) {
        throw new HttpsError(
            "permission-denied",
            "Purchase does not match the selected Premium plan.",
        );
      }

      const state = purchase.subscriptionState || "";

      const expiryTime = matchingItem.expiryTime || null;

      const now = Date.now();
      const expiryMs = expiryTime ?
        Date.parse(expiryTime) :
        0;

      const isActive =
        ACTIVE_STATES.has(state) &&
        expiryMs > now;

      const entitlementRef = db
          .collection("premium_entitlements")
          .doc(request.auth.uid);

      // Bind the verified Play purchase token to exactly one FraudRoko account.
      // This prevents another logged-in account from reusing a token already.
      // belongs to a different account. Only a SHA-256 hash is stored.
      const purchaseTokenHash = crypto
          .createHash("sha256")
          .update(token, "utf8")
          .digest("hex");

      const tokenOwnerSnapshot = await db
          .collection("premium_entitlements")
          .where("purchaseTokenHash", "==", purchaseTokenHash)
          .limit(1)
          .get();

      if (!tokenOwnerSnapshot.empty) {
        const tokenOwnerDoc = tokenOwnerSnapshot.docs[0];
        if (tokenOwnerDoc.id !== request.auth.uid) {
          throw new HttpsError(
              "already-exists",
              "This Google Play purchase is already linked to another account.",
          );
        }
      }

      if (!isActive) {
        await entitlementRef.set({
          status: "free",
          productId: requestedProductId,
          subscriptionState: state,
          expiresAt: expiryTime,
          purchaseTokenHash: purchaseTokenHash,
          updatedAt: FieldValue.serverTimestamp(),
        }, {merge: true});

        return {
          verified: true,
          premium: false,
          status: state || "UNKNOWN",
        };
      }

      /*
       * Store the verified entitlement.
       * Premium is granted ONLY after Google verification.
       */
      await entitlementRef.set({
        status: "active",
        productId: requestedProductId,
        subscriptionState: state,
        expiresAt: expiryTime,
        purchaseTokenHash: purchaseTokenHash,
        purchaseTokenVerified: true,
        updatedAt: FieldValue.serverTimestamp(),
      }, {merge: true});

      /*
       * Acknowledge the subscription after successful verification.
       * Google requires subscription purchases to be acknowledged.
       */
      try {
        await play.purchases.subscriptions.acknowledge({
          packageName: PACKAGE_NAME,
          subscriptionId: requestedProductId,
          token: token,
          requestBody: {},
        });
      } catch (error) {
        console.error(
            "Subscription acknowledgement failed:",
            (error && error.response && error.response.data) || error.message,
        );

        /*
         * Do not revoke the verified entitlement just because
         * acknowledgement encountered a temporary backend error.
         * The next verification can retry acknowledgement.
         */
      }

      return {
        verified: true,
        premium: true,
        productId: requestedProductId,
        expiresAt: expiryTime,
      };
    },
);

/**
 * Sends an FCM notification whenever a new Cyber News document
 * is created in Firestore.
 *
 * Firestore path:
 * cyber_news/{newsId}
 */
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {getMessaging} = require("firebase-admin/messaging");

exports.notifyNewCyberNews = onDocumentCreated(
    "cyber_news/{newsId}",
    async (event) => {
      const snapshot = event.data;

      if (!snapshot) {
        console.error("Cyber News trigger: document data missing.");
        return;
      }

      const data = snapshot.data() || {};
      const newsId = event.params.newsId;

      const titleHi = typeof data.titleHi === "string" ?
        data.titleHi.trim() :
        "";

      const titleMr = typeof data.titleMr === "string" ?
        data.titleMr.trim() :
        "";

      const titleEn = typeof data.titleEn === "string" ?
        data.titleEn.trim() :
        "";

      // Use English as the FCM notification title because one
      // topic notification is delivered to users with different
      // language preferences. The app will later localize the
      // notification display where appropriate.
      const title = titleEn || titleHi || titleMr || "Cyber News";

      const summaryEn = typeof data.summaryEn === "string" ?
        data.summaryEn.trim() :
        "";

      const summaryHi = typeof data.summaryHi === "string" ?
        data.summaryHi.trim() :
        "";

      const summaryMr = typeof data.summaryMr === "string" ?
        data.summaryMr.trim() :
        "";

      const body = summaryEn || summaryHi || summaryMr ||
          "New cyber security news is available.";

      try {
        await getMessaging().send({
          topic: "cyber_news",
          notification: {
            title: title,
            body: body.length > 160 ?
              `${body.substring(0, 157)}...` :
              body,
          },
          data: {
            type: "cyber_news",
            newsId: newsId,
          },
          android: {
            priority: "high",
            notification: {
              channelId: "fraudroko_security",
            },
          },
        });

        console.log(`Cyber News notification sent: ${newsId}`);
      } catch (error) {
        console.error(
            "Cyber News notification failed:",
            error,
        );
      }
    },
);


/**
 * Permanently deletes the authenticated FraudRoko account.
 *
 * Deletes account-specific access data:
 * - Premium entitlement
 * - Course entitlements
 * - Firebase Authentication user
 *
 * Payment records are intentionally retained separately.
 *
 * Firestore writes are kept below the 500-operation batch limit.
 */
exports.deleteMyAccount = onCall(
    async (request) => {
      if (!request.auth) {
        throw new HttpsError(
            "unauthenticated",
            "Login required.",
        );
      }

      const uid = request.auth.uid;

      try {
        const premiumRef = db
            .collection("premium_entitlements")
            .doc(uid);
        const courseSnapshot = await db
            .collection("course_entitlements")
            .where("uid", "==", uid)
            .get();

        /*
         * Firestore batches have a 500-operation limit.
         * Keep each batch below that limit so account deletion
         * continues to work even if the user has many purchases.
         */
        const documentsToDelete = [
          premiumRef,
          ...courseSnapshot.docs.map((document) => document.ref),
        ];

        const batchSize = 450;

        for (let index = 0;
          index < documentsToDelete.length;
          index += batchSize) {
          const batch = db.batch();
          const chunk = documentsToDelete.slice(
              index,
              index + batchSize,
          );

          chunk.forEach((documentRef) => {
            batch.delete(documentRef);
          });

          await batch.commit();
        }

        /*
         * Authentication deletion happens only after all
         * account-specific Firestore access data is removed.
         */
        try {
          await getAuth().deleteUser(uid);
        } catch (authError) {
          if (authError.code !== "auth/user-not-found") {
            throw authError;
          }

          /*
           * The Auth account is already gone, so the requested
           * account deletion is effectively complete.
           */
        }

        console.log(
            `FraudRoko account deleted successfully for UID: ${uid}`,
        );

        return {
          deleted: true,
        };
      } catch (error) {
        console.error(
            "FraudRoko account deletion failed:",
            error,
        );

        throw new HttpsError(
            "internal",
            "Unable to delete account.",
        );
      }
    },
);
