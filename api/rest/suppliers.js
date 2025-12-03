export default async function handler(req, res) {
  console.log(`➡ PROXY (suppliers): method=${req.method}`);

  // Mock data for suppliers
  const mockSuppliers = [
    { id: '1', code: 'FORN01', name: 'Fornecedor A Ltda', cnpj: '11.111.111/0001-11', active: true },
    { id: '2', code: 'FORN02', name: 'Fornecedor B S/A', cnpj: '22.222.222/0001-22', active: true },
    { id: '3', code: 'FORN03', name: 'Fornecedor C ME', cnpj: '33.333.333/0001-33', active: true },
  ];

  // Return mock for development
  res.setHeader('Content-Type', 'application/json');
  res.status(200).json(mockSuppliers);
}
