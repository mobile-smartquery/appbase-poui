export default async function handler(req, res) {
  const backendUrl =
    "http://protheusawsmobile.ddns.net:8080" + req.url.replace("/rest", "");

  console.log("➡ PROXY:", backendUrl);

  try {
    const response = await fetch(backendUrl, {
      method: req.method,
      headers: { ...req.headers, host: undefined },
      body: req.method !== "GET" ? req.body : undefined,
    });

    const data = await response.arrayBuffer();
    res.status(response.status).send(Buffer.from(data));
  } catch (err) {
    console.error("❌ PROXY ERROR:", err);
    res.status(500).json({ error: "Proxy failed" });
  }
}
