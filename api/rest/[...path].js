export default async function handler(req, res) {
  // The backend API expects requests under the '/rest' prefix.
  // Use the backend base including '/rest' so final URL becomes
  // http://protheusawsmobile.ddns.net:8080/rest/<subpath>
  const backendBase = "http://protheusawsmobile.ddns.net:8080/rest";

  const originalUrl = req.url || "";
  // When Vercel routes to this catch-all, req.url should contain the subpath
  // starting after /api/rest, but we defensively search for '/rest' or '/api/rest'.
  let forwardPath = originalUrl;

  const idxRest = originalUrl.indexOf("/rest");
  if (idxRest !== -1) {
    // keep the part after '/rest' (e.g. '/api/oauth2/v1/token')
    forwardPath = originalUrl.slice(idxRest + "/rest".length) || "/";
  } else {
    const idxApiRest = originalUrl.indexOf("/api/rest");
    if (idxApiRest !== -1) {
      // if Vercel forwarded '/api/rest/..' keep the part after that
      forwardPath = originalUrl.slice(idxApiRest + "/api/rest".length) || "/";
    }
  }

  if (!forwardPath.startsWith("/")) forwardPath = "/" + forwardPath;

  const backendUrl = backendBase + forwardPath;

  console.log("➡ PROXY (catch-all):", backendUrl);

  try {
    const response = await fetch(backendUrl, {
      method: req.method,
      headers: { ...req.headers, host: undefined },
      body: req.method !== "GET" ? req.body : undefined,
    });

    const data = await response.arrayBuffer();
    res.status(response.status).send(Buffer.from(data));
  } catch (err) {
    console.error("❌ PROXY ERROR (catch-all):", err);
    res.status(500).json({ error: "Proxy failed" });
  }
}
