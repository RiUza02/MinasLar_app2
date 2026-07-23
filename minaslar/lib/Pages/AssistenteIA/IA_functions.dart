// ignore_for_file: file_names, camel_case_types
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// [Objetivo] Camada de serviço responsável pela comunicação entre o aplicativo e a Inteligência Artificial via Supabase Edge Functions.
///
/// [Fluxo]
/// 1. Instancia o cliente nativo do Supabase.
/// 2. Invoca a Edge Function remota (`assistente-ia`) com o texto submetido no payload, gerenciando a autenticação via headers de forma implícita.
/// 3. Realiza o parse da resposta JSON ou intercepta exceções retornando uma mensagem de fallback.
class IA_functions {
  // [Dependência] Acesso ao cliente global do Supabase pré-inicializado na aplicação.
  final _supabase = Supabase.instance.client;

  /// [Objetivo] Envia o prompt do usuário para a infraestrutura serverless e retorna o texto gerado.
  ///
  /// [Comportamento]
  /// - Dispara uma chamada HTTPS remota passando um mapa com a chave 'pergunta'.
  /// - Converte a resposta em tempo de execução de forma defensiva para evitar quebras por nulos ou mudanças de tipagem no JSON.
  /// - Intercepta falhas de rede, timeouts ou erros internos da Edge Function, isolando a interface (UI) de exceções fatais.
  Future<String> perguntarParaIA({required String perguntaUsuario}) async {
    try {
      // [Integração] Aciona a Edge Function no Supabase.
      final resposta = await _supabase.functions.invoke(
        'assistente-ia',
        body: {'pergunta': perguntaUsuario},
      );

      // [Segurança de Tipagem] Parse seguro do payload retornado para prevenir TypeError na UI caso a chave não exista.
      final dados = resposta.data as Map<String, dynamic>?;
      return dados?['resposta']?.toString() ??
          "Não foi possível processar a resposta do assistente.";
    } catch (erro) {
      // [Tratamento de Erros] Registra detalhes no console exclusivamente em modo debug e provê resposta de contingência.
      debugPrint("ERRO DETALHADO DA IA: $erro");
      return "Desculpe, ocorreu um erro na comunicação com o assistente.";
    }
  }
}
