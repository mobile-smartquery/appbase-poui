export default async function handler(req, res) {
  const id = req.query.id || "UNKNOWN";

  console.log(`➡ PROXY (browse columns): id=${id}, method=${req.method}`);

  try {
    // Try to fetch from backend
    const backendUrl = `http://protheusawsmobile.ddns.net:8080/rest/dictionary/browse/columns/${id}`;

    console.log(`➡ Attempting to fetch from backend: ${backendUrl}`);

    const response = await fetch(backendUrl, {
      method: req.method || "GET",
      headers: req.headers || {},
    });

    console.log(`➡ Backend response status: ${response.status}`);

    if (response.ok) {
      const data = await response.arrayBuffer();
      res.status(response.status);
      Object.entries(response.headers).forEach(([key, value]) => {
        res.setHeader(key, value);
      });
      res.send(Buffer.from(data));
      return;
    }

    // If backend returns 404, return a mock response to prevent UI errors
    if (response.status === 404) {
      console.log("⚠ Backend returned 404; returning mock data");
      // Return empty columns array as fallback
      res.status(200).json([]);
      return;
    }

    // Otherwise forward the error
    const errorData = await response.text();
    res.status(response.status).send(errorData);
  } catch (err) {
    console.error(`❌ PROXY ERROR (browse columns): ${err.message}`);
    // Return empty array to prevent UI from breaking
    res.status(200).json([]);
  }
}
