import { createClient } from "https://esm.sh/@supabase/supabase-js@2"
import { MANUAL_DO_APP } from "./manual.ts"

/// [TODO] comando apra atualizar a IA: supabase functions deploy assistente-ia --project-ref nnbejmzhldrwaczsntzd
const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY")

Deno.serve(async (req: Request) => {
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Content-Type': 'application/json',
  }

  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers })
  }

  try {
    const body = await req.json()
    const pergunta = body.pergunta

    if (!GEMINI_API_KEY) {
      throw new Error("A chave GEMINI_API_KEY não foi configurada nos Secrets.")
    }

    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite:generateContent?key=${GEMINI_API_KEY}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          // USAMOS A VARIÁVEL IMPORTADA AQUI:
          system_instruction: {
            parts: [{ text: MANUAL_DO_APP }]
          },
          contents: [{ parts: [{ text: pergunta }] }],
        }),
      }
    )

    const data = await response.json()

    if (!response.ok) {
      throw new Error(`Erro na API do Gemini: ${JSON.stringify(data.error?.message || data)}`)
    }

    const respostaIA = data.candidates?.[0]?.content?.parts?.[0]?.text || "Não consegui obter uma resposta da IA."

    return new Response(
      JSON.stringify({ resposta: respostaIA }),
      { headers }
    )
  } catch (error: any) {
    console.error("ERRO NA FUNCTION:", error.message)
    return new Response(
      JSON.stringify({ resposta: `Erro: ${error.message}` }),
      { status: 500, headers }
    )
  }
})