import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'exceptions.dart';

class ErrorHandler {
  ErrorHandler._();

  /// [Uso]: Intercepta qualquer exceção bruta e mapeia para uma mensagem amigável catalogada.
  static String mapearErro(Object error) {
    // 1. Se já for um erro nosso do app, apenas retorna a própria mensagem.
    if (error is AppException) {
      return error.message;
    }

    // 2. Se for um erro nativo do Supabase ou banco de dados (Postgres)
    if (error is PostgrestException) {
      return _catalogarErroBanco(error.toString());
    }

    // 3. Se for erro de internet (SocketException / Timeout do Dart)
    if (error is SocketException) {
      return 'Sem conexão com a internet. Verifique seu Wi-Fi ou dados móveis.';
    }

    // 4. Se o erro for jogado apenas como texto comum (throw 'Minha mensagem')
    if (error is String) {
      return _catalogarErroString(error);
    }

    // 5. Se for um erro de localização
    if (error is LocationException) {
      return error.message;
    }

    // 6. Se for qualquer outro tipo de objeto convertendo pra texto
    return _catalogarErroString(error.toString());
  }

  /// [Uso]: Dicionário que busca palavras-chave nos erros do Supabase/Postgres e traduz.
  static String _catalogarErroBanco(String erroBruto) {
    final erroLimpado = erroBruto.toLowerCase();

    // --- CATALOGO DE ERROS DO SUPABASE / POSTGRESQL ---
    if (erroLimpado.contains('nome de usuário ou senha incorretos')) {
      return 'Usuário ou senha inválidos.';
    }
    if (erroLimpado.contains('ainda não foi liberada') ||
        erroLimpado.contains('autenticado')) {
      return 'Sua conta ainda está em análise por um administrador.';
    }
    if (erroLimpado.contains('duplicate key') ||
        erroLimpado.contains('unique constraint')) {
      if (erroLimpado.contains('telefone')) {
        return 'Este número de telefone já está cadastrado no sistema.';
      }
      return 'Este registro já existe no sistema.';
    }
    if (erroLimpado.contains('network') || erroLimpado.contains('connection')) {
      return 'Falha ao conectar com o servidor. Tente novamente mais tarde.';
    }

    return 'Erro ao processar dados no servidor.';
  }

  /// [Uso]: Limpa e cataloga strings de erro geradas manualmente pela aplicação.
  static String _catalogarErroString(String erroBruto) {
    // Remove prefixos comuns do Dart se houver
    String limpo = erroBruto.replaceAll('Exception: ', '').trim();

    // --- CATALOGO DE ERROS MANUAIS ---
    if (limpo.contains('Nome de usuário ou senha incorretos')) {
      return 'Usuário ou senha inválidos. Verifique os dados digitados.';
    }
    if (limpo.contains('não foi liberada')) {
      return 'Sua conta está aguardando liberação do administrador.';
    }

    // Se já for uma mensagem limpa que você disparou no código, retorna ela mesma
    return limpo;
  }
}
