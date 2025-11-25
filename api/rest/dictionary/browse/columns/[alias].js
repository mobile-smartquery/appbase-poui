export default function handler(req, res) {
  const alias = (req.query && req.query.alias) || (req.url || '').split('/').pop();

  // Provide a simple mock for alias 'PX2' and a generic fallback
  const sampleColumns = {
    PX2: [
      { property: 'code', label: 'Código', type: 'C', virtual: false },
      { property: 'description', label: 'Descrição', type: 'C', virtual: false },
      { property: 'active', label: 'Ativo', type: 'L', virtual: false }
    ]
  };

  const columns = sampleColumns[alias] || [
    { property: 'id', label: 'ID', type: 'C', virtual: false },
    { property: 'name', label: 'Nome', type: 'C', virtual: false }
  ];

  res.setHeader('Content-Type', 'application/json');
  res.status(200).send(JSON.stringify(columns));
}
