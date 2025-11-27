export default async function handler(req, res) {
  // Accept either query id or last path segment as id/alias
  const id = req.query.id || (req.url || "").split("/").pop() || "UNKNOWN";

  console.log(`➡ PROXY (browse columns): id/alias=${id}, method=${req.method}`);

  // Mock columns for known aliases to keep UI stable (compat with previous [alias].js)
  const sampleColumns = {
    PX2: [
      { property: "code", label: "Código", type: "C", virtual: false },
      {
        property: "description",
        label: "Descrição",
        type: "C",
        virtual: false,
      },
      { property: "active", label: "Ativo", type: "L", virtual: false },
    ],
  };

  if (sampleColumns[id]) {
    res.setHeader("Content-Type", "application/json");
    res.status(200).send(JSON.stringify(sampleColumns[id]));
    return;
  }

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

    // If backend returns 404, return a stable mock to avoid UI break
    if (response.status === 404) {
      console.log("⚠ Backend returned 404; returning fallback columns");
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
