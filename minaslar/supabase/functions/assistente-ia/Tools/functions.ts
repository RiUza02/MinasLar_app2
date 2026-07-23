// tools/definitions.ts

export const GEMINI_TOOLS = [
  {
    function_declarations: [
      {
        name: "buscar_cliente_por_nome",
        description: "Busca informações de um cliente cadastrado no banco de dados pelo seu nome ou parte dele.",
        parameters: {
          type: "OBJECT",
          properties: {
            nome: {
              type: "STRING",
              description: "Nome ou parte do nome do cliente para pesquisar.",
            },
          },
          required: ["nome"],
        },
      },
      {
        name: "listar_orcamentos_do_dia",
        description: "Lista os orçamentos e agendamentos marcados para uma data específica.",
        parameters: {
          type: "OBJECT",
          properties: {
            data: {
              type: "STRING",
              description: "Data no formato AAAA-MM-DD (ex: 2026-07-23).",
            },
          },
          required: ["data"],
        },
      },
    ],
  },
];