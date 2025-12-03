export default async function handler(req, res) {
  const { alias } = req.query;
  const pathAlias = (req.url || '').split('/').pop();
  const finalAlias = alias || pathAlias || 'UNKNOWN';

  console.log(`➡ PROXY (dictionary/struct): alias=${finalAlias}, method=${req.method}`);

  // Mock structure data for common aliases
  const mockStructures = {
    'SC7': [ // Purchase Order Header
      { field: 'C7_NUM', label: 'Pedido', type: 'C', size: 6, required: true },
      { field: 'C7_EMISSAO', label: 'Data Emissão', type: 'D', size: 8, required: true },
      { field: 'C7_FORNECE', label: 'Fornecedor', type: 'C', size: 6, required: true },
      { field: 'C7_LOJA', label: 'Loja', type: 'C', size: 2, required: true },
      { field: 'C7_COND', label: 'Condição Pagto', type: 'C', size: 3, required: false },
    ],
    'DEFAULT': [
      { field: 'ID', label: 'ID', type: 'C', size: 10, required: true },
      { field: 'DESCRICAO', label: 'Descrição', type: 'C', size: 40, required: true },
      { field: 'ATIVO', label: 'Ativo', type: 'L', size: 1, required: false },
    ]
  };

  const structure = mockStructures[finalAlias] || mockStructures['DEFAULT'];

  res.setHeader('Content-Type', 'application/json');
  res.status(200).json(structure);
}
