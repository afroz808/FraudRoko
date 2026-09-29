import {
  createRemoteJWKSet,
  importPKCS8,
  jwtVerify,
  SignJWT,
} from "jose";

const PROJECT_ID = "fraudroko-654c1";
const PACKAGE_NAME = "com.fraudroko.fraudroko_app";

const ALLOWED_PRODUCTS = new Set([
  "fraudroko_premium_monthly",
  "fraudroko_premium_yearly",
]);

const ACTIVE_STATES = new Set([
  "SUBSCRIPTION_STATE_ACTIVE",
  "SUBSCRIPTION_STATE_IN_GRACE_PERIOD",
]);

const FIREBASE_ISSUER = `https://securetoken.google.com/${PROJECT_ID}`;

const FIREBASE_JWKS = createRemoteJWKSet(
  new URL(
    "https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com",
  ),
);

const GOOGLE_OAUTH_TOKEN_URL = "https://oauth2.googleapis.com/token";
const GOOGLE_PLAY_SCOPE =
  "https://www.googleapis.com/auth/androidpublisher";
const GOOGLE_CLOUD_SCOPE =
  "https://www.googleapis.com/auth/cloud-platform";

const jsonHeaders = {
  "content-type": "application/json; charset=utf-8",
  "cache-control": "no-store",
};

function responseJson(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...jsonHeaders,
      "access-control-allow-origin": "*",
      "access-control-allow-headers": "authorization, content-type",
      "access-control-allow-methods": "POST, OPTIONS",
    },
  });
}

function base64UrlEncode(value) {
  const bytes =
    value instanceof Uint8Array
      ? value
      : new TextEncoder().encode(value);

  let binary = "";
  const chunkSize = 0x8000;

  for (let i = 0; i < bytes.length; i += chunkSize) {
    binary += String.fromCharCode(
      ...bytes.subarray(i, Math.min(i + chunkSize, bytes.length)),
    );
  }

  return btoa(binary)
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/g, "");
}

async function sha256Hex(value) {
  const digest = await crypto.subtle.digest(
    "SHA-256",
    new TextEncoder().encode(value),
  );

  return Array.from(new Uint8Array(digest))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

function parseBearer(request) {
  const value = request.headers.get("authorization") || "";

  if (!value.startsWith("Bearer ")) {
    return null;
  }

  const token = value.slice("Bearer ".length).trim();

  if (!token || token.length > 10000) {
    return null;
  }

  return token;
}

async function verifyFirebaseIdToken(idToken) {
  const { payload } = await jwtVerify(
    idToken,
    FIREBASE_JWKS,
    {
      algorithms: ["RS256"],
      issuer: FIREBASE_ISSUER,
      audience: PROJECT_ID,
    },
  );

  if (
    typeof payload.sub !== "string" ||
    payload.sub.length === 0 ||
    payload.sub.length > 128
  ) {
    throw new Error("Invalid Firebase subject");
  }

  return payload.sub;
}

async function getServiceAccount(env) {
  if (!env.GOOGLE_SERVICE_ACCOUNT_JSON) {
    throw new Error("Google service account secret is not configured");
  }

  let credentials;

  try {
    credentials = JSON.parse(env.GOOGLE_SERVICE_ACCOUNT_JSON);
  } catch {
    throw new Error("Google service account secret is invalid JSON");
  }

  if (
    credentials.type !== "service_account" ||
    typeof credentials.client_email !== "string" ||
    typeof credentials.private_key !== "string"
  ) {
    throw new Error("Google service account secret is incomplete");
  }

  return credentials;
}

async function getGoogleAccessToken(env) {
  const credentials = await getServiceAccount(env);

  const privateKey = await importPKCS8(
    credentials.private_key,
    "RS256",
  );

  const now = Math.floor(Date.now() / 1000);

  const assertion = await new SignJWT({
    scope: `${GOOGLE_PLAY_SCOPE} ${GOOGLE_CLOUD_SCOPE}`,
  })
    .setProtectedHeader({
      alg: "RS256",
      typ: "JWT",
    })
    .setIssuer(credentials.client_email)
    .setAudience(GOOGLE_OAUTH_TOKEN_URL)
    .setIssuedAt(now)
    .setExpirationTime(now + 3600)
    .sign(privateKey);

  const response = await fetch(GOOGLE_OAUTH_TOKEN_URL, {
    method: "POST",
    headers: {
      "content-type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({
      grant_type:
        "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion,
    }),
  });

  if (!response.ok) {
    throw new Error("Google OAuth token request failed");
  }

  const data = await response.json();

  if (
    typeof data.access_token !== "string" ||
    data.access_token.length < 20
  ) {
    throw new Error("Google OAuth token missing");
  }

  return data.access_token;
}

async function googlePlayGet(accessToken, purchaseToken) {
  const url =
    "https://androidpublisher.googleapis.com/androidpublisher/v3" +
    `/applications/${encodeURIComponent(PACKAGE_NAME)}` +
    `/purchases/subscriptionsv2/tokens/${encodeURIComponent(purchaseToken)}`;

  const response = await fetch(url, {
    method: "GET",
    headers: {
      authorization: `Bearer ${accessToken}`,
      accept: "application/json",
    },
  });

  if (!response.ok) {
    throw new Error("Google Play purchase verification failed");
  }

  return response.json();
}

async function acknowledgeSubscription(
  accessToken,
  productId,
  purchaseToken,
) {
  const url =
    "https://androidpublisher.googleapis.com/androidpublisher/v3" +
    `/applications/${encodeURIComponent(PACKAGE_NAME)}` +
    `/purchases/subscriptions/${encodeURIComponent(productId)}` +
    `/tokens/${encodeURIComponent(purchaseToken)}:acknowledge`;

  const response = await fetch(url, {
    method: "POST",
    headers: {
      authorization: `Bearer ${accessToken}`,
      "content-type": "application/json",
    },
    body: "{}",
  });

  if (!response.ok) {
    throw new Error("Subscription acknowledgement failed");
  }
}

function firestoreValue(value) {
  if (typeof value === "string") {
    return { stringValue: value };
  }

  if (typeof value === "boolean") {
    return { booleanValue: value };
  }

  throw new Error("Unsupported Firestore value");
}

function firestoreTimestamp(dateString) {
  return {
    timestampValue: dateString,
  };
}

async function firestoreGetDocument(accessToken, uid) {
  const url =
    "https://firestore.googleapis.com/v1" +
    `/projects/${PROJECT_ID}` +
    `/databases/(default)/documents/premium_entitlements/${encodeURIComponent(uid)}`;

  const response = await fetch(url, {
    method: "GET",
    headers: {
      authorization: `Bearer ${accessToken}`,
      accept: "application/json",
    },
  });

  if (response.status === 404) {
    return null;
  }

  if (!response.ok) {
    throw new Error("Firestore entitlement read failed");
  }

  return response.json();
}

async function firestoreFindTokenOwner(accessToken, purchaseTokenHash) {
  const url =
    "https://firestore.googleapis.com/v1" +
    `/projects/${PROJECT_ID}` +
    `/databases/(default)/documents:runQuery`;

  const query = {
    structuredQuery: {
      from: [
        {
          collectionId: "premium_entitlements",
        },
      ],
      where: {
        fieldFilter: {
          field: {
            fieldPath: "purchaseTokenHash",
          },
          op: "EQUAL",
          value: {
            stringValue: purchaseTokenHash,
          },
        },
      },
      limit: 1,
    },
  };

  const response = await fetch(url, {
    method: "POST",
    headers: {
      authorization: `Bearer ${accessToken}`,
      "content-type": "application/json",
    },
    body: JSON.stringify(query),
  });

  if (!response.ok) {
    throw new Error("Firestore token lookup failed");
  }

  const rows = await response.json();

  for (const row of rows) {
    if (row.document?.name) {
      const parts = row.document.name.split("/");
      return parts[parts.length - 1] || null;
    }
  }

  return null;
}

async function firestoreWriteEntitlement(
  accessToken,
  uid,
  fields,
) {
  const url =
    "https://firestore.googleapis.com/v1" +
    `/projects/${PROJECT_ID}` +
    `/databases/(default)/documents/premium_entitlements/${encodeURIComponent(uid)}`;

  const response = await fetch(url, {
    method: "PATCH",
    headers: {
      authorization: `Bearer ${accessToken}`,
      "content-type": "application/json",
    },
    body: JSON.stringify({
      fields,
    }),
  });

  if (!response.ok) {
    throw new Error("Firestore entitlement write failed");
  }
}

function currentEntitlementIsActive(document) {
  const fields = document?.fields;

  if (!fields) {
    return false;
  }

  if (fields.status?.stringValue !== "active") {
    return false;
  }

  const expiry =
    fields.expiresAt?.timestampValue ||
    fields.expiresAt?.stringValue ||
    null;

  if (!expiry) {
    return false;
  }

  const expiryMs = Date.parse(expiry);

  return Number.isFinite(expiryMs) && expiryMs > Date.now();
}

async function verifyPurchase(request, env) {
  const idToken = parseBearer(request);

  if (!idToken) {
    return responseJson(
      {
        verified: false,
        error: "Login required.",
      },
      401,
    );
  }

  let uid;

  try {
    uid = await verifyFirebaseIdToken(idToken);
  } catch {
    return responseJson(
      {
        verified: false,
        error: "Invalid authentication.",
      },
      401,
    );
  }

  const contentLength = Number(
    request.headers.get("content-length") || "0",
  );

  if (contentLength > 16384) {
    return responseJson(
      {
        verified: false,
        error: "Request too large.",
      },
      413,
    );
  }

  let data;

  try {
    const raw = await request.text();

    if (raw.length > 16384) {
      return responseJson(
        {
          verified: false,
          error: "Request too large.",
        },
        413,
      );
    }

    data = JSON.parse(raw);
  } catch {
    return responseJson(
      {
        verified: false,
        error: "Invalid request.",
      },
      400,
    );
  }

  const token = data?.purchaseToken;
  const requestedProductId = data?.productId;

  if (
    typeof token !== "string" ||
    token.length < 20 ||
    token.length > 4096
  ) {
    return responseJson(
      {
        verified: false,
        error: "Invalid purchase token.",
      },
      400,
    );
  }

  if (
    typeof requestedProductId !== "string" ||
    !ALLOWED_PRODUCTS.has(requestedProductId)
  ) {
    return responseJson(
      {
        verified: false,
        error: "Invalid Premium product.",
      },
      400,
    );
  }

  try {
    const accessToken = await getGoogleAccessToken(env);

    const purchase = await googlePlayGet(
      accessToken,
      token,
    );

    const lineItems = Array.isArray(purchase.lineItems)
      ? purchase.lineItems
      : [];

    const matchingItem = lineItems.find(
      (item) => item.productId === requestedProductId,
    );

    if (!matchingItem) {
      return responseJson(
        {
          verified: false,
          error: "Purchase does not match the selected Premium plan.",
        },
        403,
      );
    }

    const state = purchase.subscriptionState || "";
    const expiryTime = matchingItem.expiryTime || null;
    const expiryMs = expiryTime
      ? Date.parse(expiryTime)
      : 0;

    const isActive =
      ACTIVE_STATES.has(state) &&
      Number.isFinite(expiryMs) &&
      expiryMs > Date.now();

    const purchaseTokenHash = await sha256Hex(token);

    const tokenOwner = await firestoreFindTokenOwner(
      accessToken,
      purchaseTokenHash,
    );

    if (tokenOwner && tokenOwner !== uid) {
      return responseJson(
        {
          verified: false,
          error:
            "This Google Play purchase is already linked to another account.",
        },
        409,
      );
    }

    const currentDocument = await firestoreGetDocument(
      accessToken,
      uid,
    );

    if (!isActive) {
      // Never downgrade a still-valid entitlement because an old/expired
      // purchase token was submitted.
      if (currentEntitlementIsActive(currentDocument)) {
        return responseJson({
          verified: true,
          premium: true,
          status: "ACTIVE",
          preservedExistingEntitlement: true,
        });
      }

      await firestoreWriteEntitlement(
        accessToken,
        uid,
        {
          status: firestoreValue("free"),
          productId: firestoreValue(requestedProductId),
          subscriptionState: firestoreValue(state),
          expiresAt: expiryTime
            ? firestoreTimestamp(expiryTime)
            : firestoreValue(""),
          purchaseTokenHash: firestoreValue(purchaseTokenHash),
          updatedAt: firestoreTimestamp(
            new Date().toISOString(),
          ),
        },
      );

      return responseJson({
        verified: true,
        premium: false,
        status: state || "UNKNOWN",
      });
    }

    await firestoreWriteEntitlement(
      accessToken,
      uid,
      {
        status: firestoreValue("active"),
        productId: firestoreValue(requestedProductId),
        subscriptionState: firestoreValue(state),
        expiresAt: firestoreTimestamp(expiryTime),
        purchaseTokenHash: firestoreValue(purchaseTokenHash),
        purchaseTokenVerified: firestoreValue(true),
        updatedAt: firestoreTimestamp(
          new Date().toISOString(),
        ),
      },
    );

    // Acknowledge only after successful Google Play verification.
    // Acknowledgement failure must not revoke a verified entitlement.
    try {
      await acknowledgeSubscription(
        accessToken,
        requestedProductId,
        token,
      );
    } catch (error) {
      console.error(
        "Subscription acknowledgement failed:",
        error instanceof Error ? error.message : "unknown",
      );
    }

    return responseJson({
      verified: true,
      premium: true,
      productId: requestedProductId,
      expiresAt: expiryTime,
    });
  } catch (error) {
    console.error(
      "Premium verification failed:",
      error instanceof Error ? error.message : "unknown",
    );

    return responseJson(
      {
        verified: false,
        error: "Payment verification is temporarily unavailable.",
      },
      503,
    );
  }
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (request.method === "OPTIONS") {
      return new Response(null, {
        status: 204,
        headers: {
          "access-control-allow-origin": "*",
          "access-control-allow-headers":
            "authorization, content-type",
          "access-control-allow-methods": "POST, OPTIONS",
        },
      });
    }

    if (request.method === "GET" && url.pathname === "/health") {
      return responseJson({
        service: "fraudroko-play-verify",
        status: "worker-online",
      });
    }

    if (
      request.method === "POST" &&
      url.pathname === "/verify"
    ) {
      return verifyPurchase(request, env);
    }

    return responseJson(
      {
        error: "Not found",
      },
      404,
    );
  },
};
