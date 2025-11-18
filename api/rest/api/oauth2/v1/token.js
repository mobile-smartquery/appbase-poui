export default async function handler(req, res) {
  const backendUrl =
    "http://protheusawsmobile.ddns.net:8080/rest/api/oauth2/v1/token";

  console.log("➡ PROXY (token):", backendUrl);

  try {
    console.log("➡ PROXY (token) incoming:", {
      method: req.method,
      url: req.url,
    });
    // Log content-type / prepared body for debugging (truncate)
    // Note: avoid logging sensitive credentials in production; temporary for debugging.
    const ct = headers["content-type"] || headers["Content-Type"];
    console.log("➡ PROXY (token) prepared headers content-type:", ct);
    console.log(
      "➡ PROXY (token) prepared body length:",
      body ? String(body).length : 0
    );
    const headers = { ...(req.headers || {}) };
    // Remove host/content-length to let fetch set them correctly
    delete headers.host;
    delete headers["content-length"];

    // Normalize header values to strings
    for (const k of Object.keys(headers)) {
      if (Array.isArray(headers[k])) headers[k] = headers[k].join(",");
      else if (headers[k] === undefined || headers[k] === null)
        delete headers[k];
    }

    // Prepare body forwarding depending on content-type
    let body;
    if (req.method && req.method.toUpperCase() !== "GET") {
      const contentType = (headers["content-type"] || "").toLowerCase();
      if (contentType.includes("application/x-www-form-urlencoded")) {
        if (typeof req.body === "string") body = req.body;
        else if (req.body && typeof req.body === "object")
          body = new URLSearchParams(req.body).toString();
        else body = "";
      } else if (contentType.includes("application/json")) {
        if (typeof req.body === "string") body = req.body;
        else body = JSON.stringify(req.body || {});
      } else {
        // fallback: prefer rawBody if available (some runtimes provide it)
        body = req.rawBody || req.body;
      }
    }

    const response = await fetch(backendUrl, {
      method: req.method,
      headers,
      body,
    });

    console.log("➡ PROXY (token) fetched backend:", {
      status: response.status,
    });

    const data = await response.arrayBuffer();
    res.status(response.status).send(Buffer.from(data));
  } catch (err) {
    console.error("❌ PROXY ERROR (token):", err);
    res.status(500).json({ error: "Proxy failed" });
  }
}
