export default async function handler(req, res) {
  console.log(`➡ PROXY (companies): method=${req.method}`);

  // Mock data for companies
  const mockCompanies = [
    { id: '1', code: 'EMP01', name: 'Empresa Matriz', cnpj: '00.000.000/0001-00', active: true },
    { id: '2', code: 'EMP02', name: 'Filial São Paulo', cnpj: '00.000.000/0002-00', active: true },
    { id: '3', code: 'EMP03', name: 'Filial Rio de Janeiro', cnpj: '00.000.000/0003-00', active: true },
  ];

  // Return mock for development
  res.setHeader('Content-Type', 'application/json');
  res.status(200).json(mockCompanies);
}
