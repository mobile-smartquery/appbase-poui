export default async function handler(req, res) {
  const backendBase = "http://protheusawsmobile.ddns.net:8080";

  // Try to extract the path that comes after '/rest' in the original requested URL.
  // Vercel rewrites should forward the :path* to this function, but the req.url
  // may include prefixes like '/api/rest/...'. We look for '/rest' or '/api/rest'
  // and slice the remainder to build the backend path.
  const originalUrl = req.url || "";
  let forwardPath = originalUrl;

  const idxRest = originalUrl.indexOf("/rest");
  if (idxRest !== -1) {
    forwardPath = originalUrl.slice(idxRest + "/rest".length) || "/";
  } else {
    const idxApiRest = originalUrl.indexOf("/api/rest");
    if (idxApiRest !== -1) {
      forwardPath = originalUrl.slice(idxApiRest + "/api/rest".length) || "/";
    }
  }

  // Ensure path starts with '/'
  if (!forwardPath.startsWith("/")) forwardPath = "/" + forwardPath;

  const backendUrl = backendBase + forwardPath;

  console.log("➡ PROXY:", backendUrl);

  try {
    const response = await fetch(backendUrl, {
      method: req.method,
      headers: { ...req.headers, host: undefined },
      // If the request has a body, forward it. In many cases the frontend
      // sends parameters in the query string for this app, so body may be undefined.
      body: req.method !== "GET" ? req.body : undefined,
    });

    const data = await response.arrayBuffer();
    res.status(response.status).send(Buffer.from(data));
  } catch (err) {
    console.error("❌ PROXY ERROR:", err);
    res.status(500).json({ error: "Proxy failed" });
  }
}
