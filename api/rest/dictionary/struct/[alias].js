export default async function handler(req, res) {
  const { alias } = req.query;
  const pathAlias = (req.url || "").split("/").pop();
  const finalAlias = alias || pathAlias || "UNKNOWN";

  console.log(
    `➡ PROXY (dictionary/struct): alias=${finalAlias}, method=${req.method}`
  );

  // Mock structure data for common aliases
  const mockStructures = {
    PX2: [
      // Main contract header
      {
        field: "PX2_CONTRA",
        label: "Contrato",
        type: "C",
        size: 10,
        required: true,
      },
      {
        field: "PX2_DESCRI",
        label: "Descrição",
        type: "C",
        size: 60,
        required: true,
      },
      {
        field: "PX2_DTINIC",
        label: "Data Início",
        type: "D",
        size: 8,
        required: true,
      },
      {
        field: "PX2_DTFIM",
        label: "Data Fim",
        type: "D",
        size: 8,
        required: true,
      },
      {
        field: "PX2_VALOR",
        label: "Valor",
        type: "N",
        size: 15,
        decimal: 2,
        required: true,
      },
      {
        field: "PX2_STATUS",
        label: "Status",
        type: "C",
        size: 1,
        required: false,
      },
    ],
    PB9: [
      // Contract accounting entries
      {
        field: "PB9_CONTRA",
        label: "Contrato",
        type: "C",
        size: 10,
        required: true,
      },
      { field: "PB9_ITEM", label: "Item", type: "C", size: 4, required: true },
      {
        field: "PB9_CONTA",
        label: "Conta",
        type: "C",
        size: 20,
        required: true,
      },
      {
        field: "PB9_CC",
        label: "C. Custo",
        type: "C",
        size: 9,
        required: false,
      },
      {
        field: "PB9_VALOR",
        label: "Valor",
        type: "N",
        size: 15,
        decimal: 2,
        required: true,
      },
    ],
    PX7: [
      // Contract suppliers
      {
        field: "PX7_CONTRA",
        label: "Contrato",
        type: "C",
        size: 10,
        required: true,
      },
      { field: "PX7_ITEM", label: "Item", type: "C", size: 4, required: true },
      {
        field: "PX7_FORNEC",
        label: "Fornecedor",
        type: "C",
        size: 6,
        required: true,
      },
      { field: "PX7_LOJA", label: "Loja", type: "C", size: 2, required: true },
      {
        field: "PX7_NOME",
        label: "Nome",
        type: "C",
        size: 40,
        required: false,
      },
    ],
    PX3: [
      // Contract items
      {
        field: "PX3_CONTRA",
        label: "Contrato",
        type: "C",
        size: 10,
        required: true,
      },
      { field: "PX3_ITEM", label: "Item", type: "C", size: 4, required: true },
      {
        field: "PX3_PRODUT",
        label: "Produto",
        type: "C",
        size: 15,
        required: true,
      },
      {
        field: "PX3_DESCRI",
        label: "Descrição",
        type: "C",
        size: 60,
        required: true,
      },
      {
        field: "PX3_QUANT",
        label: "Quantidade",
        type: "N",
        size: 12,
        decimal: 2,
        required: true,
      },
      {
        field: "PX3_PRECO",
        label: "Preço Unit.",
        type: "N",
        size: 15,
        decimal: 2,
        required: true,
      },
      {
        field: "PX3_TOTAL",
        label: "Total",
        type: "N",
        size: 15,
        decimal: 2,
        required: false,
      },
    ],
    PX4: [
      // Contract companies
      {
        field: "PX4_CONTRA",
        label: "Contrato",
        type: "C",
        size: 10,
        required: true,
      },
      { field: "PX4_ITEM", label: "Item", type: "C", size: 4, required: true },
      {
        field: "PX4_EMPRES",
        label: "Empresa",
        type: "C",
        size: 2,
        required: true,
      },
      {
        field: "PX4_FILIAL",
        label: "Filial",
        type: "C",
        size: 2,
        required: true,
      },
      {
        field: "PX4_NOME",
        label: "Nome",
        type: "C",
        size: 40,
        required: false,
      },
    ],
    PX6: [
      // Contract users
      {
        field: "PX6_CONTRA",
        label: "Contrato",
        type: "C",
        size: 10,
        required: true,
      },
      { field: "PX6_ITEM", label: "Item", type: "C", size: 4, required: true },
      {
        field: "PX6_USER",
        label: "Usuário",
        type: "C",
        size: 15,
        required: true,
      },
      {
        field: "PX6_NOME",
        label: "Nome",
        type: "C",
        size: 40,
        required: true,
      },
      {
        field: "PX6_PERFIL",
        label: "Perfil",
        type: "C",
        size: 20,
        required: false,
      },
    ],
    SC7: [
      // Purchase Order Header
      { field: "C7_NUM", label: "Pedido", type: "C", size: 6, required: true },
      {
        field: "C7_EMISSAO",
        label: "Data Emissão",
        type: "D",
        size: 8,
        required: true,
      },
      {
        field: "C7_FORNECE",
        label: "Fornecedor",
        type: "C",
        size: 6,
        required: true,
      },
      { field: "C7_LOJA", label: "Loja", type: "C", size: 2, required: true },
      {
        field: "C7_COND",
        label: "Condição Pagto",
        type: "C",
        size: 3,
        required: false,
      },
    ],
    DEFAULT: [
      { field: "ID", label: "ID", type: "C", size: 10, required: true },
      {
        field: "DESCRICAO",
        label: "Descrição",
        type: "C",
        size: 40,
        required: true,
      },
      { field: "ATIVO", label: "Ativo", type: "L", size: 1, required: false },
    ],
  };

  const structure = mockStructures[finalAlias] || mockStructures["DEFAULT"];

  res.setHeader("Content-Type", "application/json");
  res.status(200).json(structure);
}
