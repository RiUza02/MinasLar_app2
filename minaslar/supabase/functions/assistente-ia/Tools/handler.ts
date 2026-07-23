// tools/handlers.ts
import { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

export async function buscarClientePorNome(supabase: SupabaseClient, args: { nome: string }) {
  const { data, error } = await supabase
    .from("clientes")
    .select("id, nome, telefone, rua, numero, bairro, eh_problematico")
    .ilike("nome", `%${args.nome}%`)
    .limit(5);

  if (error) return { erro: `Falha ao buscar cliente: ${error.message}` };
  if (!data || data.length === 0) return { mensagem: "Nenhum cliente encontrado com esse nome." };

  return { clientes: data };
}

export async function listarOrcamentosDoDia(supabase: SupabaseClient, args: { data: string }) {
  const { data, error } = await supabase
    .from("orcamentos")
    .select("id, titulo, valor, status, turno, cliente:clientes(nome)")
    .eq("data_agendamento", args.data);

  if (error) return { erro: `Falha ao buscar orçamentos: ${error.message}` };
  if (!data || data.length === 0) return { mensagem: "Nenhum orçamento encontrado para esta data." };

  return { orcamentos: data };
}