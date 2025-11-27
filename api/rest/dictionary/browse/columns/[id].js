export default async function handler(req, res) {
  // 1. Captura o parâmetro (pode ser um ID ou um Alias, é a mesma coisa aqui)
  const id = req.query.id || (req.url || "").split("/").pop() || "UNKNOWN";

  // =================================================================
  // LÓGICA 1: MOCK (Antigo alias.js)
  // Se for 'PX2', retornamos os dados falsos (mock) imediatamente
  // =================================================================
  if (id === "PX2") {
    const mockColumns = [
      { property: "code", label: "Código", type: "C", virtual: false },
      {
        property: "description",
        label: "Descrição",
        type: "C",
        virtual: false,
      },
      { property: "active", label: "Ativo", type: "L", virtual: false },
    ];

    res.setHeader("Content-Type", "application/json");
    return res.status(200).json(mockColumns);
  }

  // =================================================================
  // LÓGICA 2: PROXY BACKEND (Antigo id.js)
  // Se não for PX2, tentamos buscar no servidor Protheus
  // =================================================================

  console.log(`➡ PROXY (browse columns): id=${id}, method=${req.method}`);

  try {
    // Tenta buscar do backend
    const backendUrl = `http://protheusawsmobile.ddns.net:8080/rest/dictionary/browse/columns/${id}`;

    console.log(`➡ Tentando buscar do backend: ${backendUrl}`);

    const response = await fetch(backendUrl, {
      method: req.method || "GET",
      headers: req.headers || {},
    });

    console.log(`➡ Status da resposta do Backend: ${response.status}`);

    if (response.ok) {
      const data = await response.arrayBuffer();
      res.status(response.status);

      // Repassa os headers
      Object.entries(response.headers).forEach(([key, value]) => {
        res.setHeader(key, value);
      });

      res.send(Buffer.from(data));
      return;
    }

    // Se o backend der 404 (Não encontrado)
    if (response.status === 404) {
      console.log("⚠ Backend retornou 404; retornando fallback genérico");

      // Aqui podemos retornar aquele fallback genérico que estava no alias.js
      // caso o ID não exista no backend
      const genericFallback = [
        { property: "id", label: "ID", type: "C", virtual: false },
        { property: "name", label: "Nome", type: "C", virtual: false },
      ];

      res.status(200).json(genericFallback);
      return;
    }

    // Se for outro erro, repassa o erro
    const errorData = await response.text();
    res.status(response.status).send(errorData);
  } catch (err) {
    console.error(`❌ ERRO NO PROXY (browse columns): ${err.message}`);
    // Retorna array vazio para não quebrar a tela
    res.status(200).json([]);
  }
}
