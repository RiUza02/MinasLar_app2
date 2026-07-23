// tools/index.ts
import { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";
import { GEMINI_TOOLS } from "./definitions.ts";
import { buscarClientePorNome, listarOrcamentosDoDia } from "./handlers.ts";

export { GEMINI_TOOLS };

export async function executarTool(
  toolName: string,
  args: any,
  supabase: SupabaseClient
) {
  console.log(`🤖 Executando Tool: ${toolName}`, args);

  switch (toolName) {
    case "buscar_cliente_por_nome":
      return await buscarClientePorNome(supabase, args);

    case "listar_orcamentos_do_dia":
      return await listarOrcamentosDoDia(supabase, args);

    default:
      throw new Error(`Ferramenta '${toolName}' não foi encontrada ou configurada.`);
  }
}