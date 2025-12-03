export default async function handler(req, res) {
  console.log(`➡ PROXY (accounting): method=${req.method}`);

  // Mock data for accounting
  const mockAccounting = [
    {
      id: "1",
      account: "1.01.001",
      description: "Caixa Geral",
      type: "A",
      active: true,
    },
    {
      id: "2",
      account: "1.02.001",
      description: "Banco Conta Corrente",
      type: "A",
      active: true,
    },
    {
      id: "3",
      account: "2.01.001",
      description: "Fornecedores a Pagar",
      type: "P",
      active: true,
    },
  ];

  // Return mock for development
  res.setHeader("Content-Type", "application/json");
  res.status(200).json(mockAccounting);
}
