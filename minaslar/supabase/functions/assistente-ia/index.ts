// index.ts
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { MANUAL_DO_APP } from "./manual.ts";
import { GEMINI_TOOLS, executarTool } from "./tools/translator.ts";

const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY");

Deno.serve(async (req: Request) => {
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Content-Type': 'application/json',
  };

  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers });
  }

  try {
    const body = await req.json();
    const pergunta = body.pergunta;

    if (!GEMINI_API_KEY) {
      throw new Error("A chave GEMINI_API_KEY não foi configurada nos Secrets.");
    }

    // Inicializa o Supabase
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || Deno.env.get('SUPABASE_ANON_KEY')!;
    const supabase = createClient(supabaseUrl, supabaseKey);

    const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${GEMINI_API_KEY}`;

    // Monta o payload inicial
    const contents: any[] = [{ parts: [{ text: pergunta }] }];

    const payload = {
      system_instruction: { parts: [{ text: MANUAL_DO_APP }] },
      tools: GEMINI_TOOLS, // 👈 Injeta nossas ferramentas modularizadas
      contents: contents,
    };

    // 1ª Chamada ao Gemini
    let response = await fetch(endpoint, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    });

    let data = await response.json();
    let candidate = data.candidates?.[0]?.content;
    let functionCall = candidate?.parts?.[0]?.functionCall;

    // 2. Se o Gemini decidiu chamar uma Tool:
    if (functionCall) {
      const { name, args } = functionCall;

      // Executa a função no banco usando nosso roteador modular
      const resultadoTool = await executarTool(name, args, supabase);

      // Adiciona o histórico e a resposta da Tool para o Gemini gerar a resposta final ao usuário
      contents.push(candidate); // Resposta do Gemini solicitando a Tool
      contents.push({
        parts: [
          {
            functionResponse: {
              name: name,
              response: { content: resultadoTool },
            },
          },
        ],
      });

      // 2ª Chamada ao Gemini (enviando os dados obtidos do banco)
      response = await fetch(endpoint, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          system_instruction: { parts: [{ text: MANUAL_DO_APP }] },
          contents: contents,
        }),
      });

      data = await response.json();
    }

    const respostaIA = data.candidates?.[0]?.content?.parts?.[0]?.text || "Não consegui obter uma resposta.";

    return new Response(JSON.stringify({ resposta: respostaIA }), { headers });

  } catch (error: any) {
    console.error("ERRO NA FUNCTION:", error.message);
    return new Response(JSON.stringify({ resposta: `Erro: ${error.message}` }), { status: 500, headers });
  }
});