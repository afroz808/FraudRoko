export default {
  async fetch(request, env) {
    const corsHeaders = {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "POST, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type",
      "Content-Type": "application/json",
    };

    if (request.method === "OPTIONS") {
      return new Response(null, {
        status: 204,
        headers: corsHeaders,
      });
    }


    // Fetch an existing Cloudflare URL Scanner result.
    if (request.method === "GET") {
      const path = new URL(request.url).pathname;
      const match = path.match(/^\/result\/([0-9a-fA-F-]{36})$/);

      if (!match) {
        return new Response(
          JSON.stringify({
            success: false,
            error: "Invalid scan ID.",
          }),
          {
            status: 400,
            headers: corsHeaders,
          },
        );
      }

      const scanId = match[1];
      const originalUrl = await env.SCAN_URLS.get(scanId);

      try {
        const resultResponse = await fetch(
          `https://api.cloudflare.com/client/v4/accounts/${env.CLOUDFLARE_ACCOUNT_ID}/urlscanner/v2/result/${scanId}`,
          {
            headers: {
              "Authorization": `Bearer ${env.CLOUDFLARE_API_TOKEN}`,
            },
          },
        );

        const resultData = await resultResponse.json();

        if (!resultResponse.ok || !resultData?.data) {
          return new Response(
            JSON.stringify({
              success: false,
              status: "processing",
            }),
            {
              status: 200,
              headers: corsHeaders,
            },
          );
        }

        const overall = resultData.data?.verdicts?.overall;
        const malicious = overall?.malicious === true;
        const phishing =
          Array.isArray(resultData.data?.meta?.processors?.phishing?.data) &&
          resultData.data.meta.processors.phishing.data.length > 0;
        const phishingV2 =
          Array.isArray(resultData.data?.meta?.processors?.phishing_v2?.data) &&
          resultData.data.meta.processors.phishing_v2.data.length > 0;

        let verdict = "clear";

        if (malicious || phishing || phishingV2) {
          verdict = "danger";
        }

        return new Response(
          JSON.stringify({
            success: true,
            status: resultData.data?.task?.status || "finished",
            verdict: verdict,
            malicious: malicious,
          }),
          {
            status: 200,
            headers: corsHeaders,
          },
        );
      } catch (error) {
        console.error("Cloudflare result fetch failed:", error);

        return new Response(
          JSON.stringify({
            success: false,
            status: "unavailable",
          }),
          {
            status: 502,
            headers: corsHeaders,
          },
        );
      }
    }

    if (request.method !== "POST") {
      return new Response(
        JSON.stringify({
          success: false,
          error: "Only POST requests are allowed.",
        }),
        {
          status: 405,
          headers: corsHeaders,
        },
      );
    }

    let body;

    try {
      body = await request.json();
    } catch {
      return new Response(
        JSON.stringify({
          success: false,
          error: "Invalid request.",
        }),
        {
          status: 400,
          headers: corsHeaders,
        },
      );
    }

    const url = typeof body?.url === "string" ?
      body.url.trim() :
      "";

    if (!url) {
      return new Response(
        JSON.stringify({
          success: false,
          error: "Please provide a URL.",
        }),
        {
          status: 400,
          headers: corsHeaders,
        },
      );
    }

    let parsedUrl;

    try {
      parsedUrl = new URL(url);
    } catch {
      return new Response(
        JSON.stringify({
          success: false,
          error: "Invalid URL.",
        }),
        {
          status: 400,
          headers: corsHeaders,
        },
      );
    }

    if (!["http:", "https:"].includes(parsedUrl.protocol)) {
      return new Response(
        JSON.stringify({
          success: false,
          error: "Only HTTP and HTTPS links are supported.",
        }),
        {
          status: 400,
          headers: corsHeaders,
        },
      );
    }

    if (!env.CLOUDFLARE_API_TOKEN) {
      return new Response(
        JSON.stringify({
          success: false,
          error: "Scanner configuration is missing.",
        }),
        {
          status: 500,
          headers: corsHeaders,
        },
      );
    }

    const accountId = env.CLOUDFLARE_ACCOUNT_ID;

    if (!accountId) {
      return new Response(
        JSON.stringify({
          success: false,
          error: "Scanner account configuration is missing.",
        }),
        {
          status: 500,
          headers: corsHeaders,
        },
      );
    }

    try {
      const submitResponse = await fetch(
        `https://api.cloudflare.com/client/v4/accounts/${accountId}/urlscanner/v2/scan`,
        {
          method: "POST",
          headers: {
            "Authorization": `Bearer ${env.CLOUDFLARE_API_TOKEN}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            url,
            visibility: "unlisted",
          }),
        },
      );

      const submitData = await submitResponse.json();

      if (!submitResponse.ok || !submitData?.uuid) {
        console.error("Cloudflare submission failed:", submitData);

        return new Response(
          JSON.stringify({
            success: false,
            error: "Link scan could not be started.",
          }),
          {
            status: 502,
            headers: corsHeaders,
          },
        );
      }

      await env.SCAN_URLS.put(
        submitData.uuid,
        url,
        {expirationTtl: 3600},
      );

      return new Response(
        JSON.stringify({
          success: true,
          status: "submitted",
          scanId: submitData.uuid,
          url: url,
        }),
        {
          status: 200,
          headers: corsHeaders,
        },
      );
    } catch (error) {
      console.error("Scanner error:", error);

      return new Response(
        JSON.stringify({
          success: false,
          error: "Link scan is temporarily unavailable.",
        }),
        {
          status: 502,
          headers: corsHeaders,
        },
      );
    }
  },
};
