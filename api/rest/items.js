export default async function handler(req, res) {
  console.log(`➡ PROXY (items): method=${req.method}`);

  // Mock data for contract items
  const mockItems = [
    { id: '1', code: 'ITEM01', description: 'Serviço de Consultoria', unit: 'HR', price: 150.00, active: true },
    { id: '2', code: 'ITEM02', description: 'Desenvolvimento de Software', unit: 'HR', price: 200.00, active: true },
    { id: '3', code: 'ITEM03', description: 'Suporte Técnico', unit: 'MÊS', price: 500.00, active: true },
  ];

  // Return mock for development
  res.setHeader('Content-Type', 'application/json');
  res.status(200).json(mockItems);
}
