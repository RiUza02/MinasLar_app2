import 'package:supabase_flutter/supabase_flutter.dart';
import '../modelos/cliente_model.dart';

class ClienteRepository {
  final _supabase = Supabase.instance.client;

  /// Busca clientes por Nome, Telefone, Rua ou Bairro em uma única consulta.
  Future<List<Cliente>> buscarClientes(String termo) async {
    // 1. Se a pesquisa estiver vazia, retorna os 20 primeiros clientes em ordem alfabética
    if (termo.trim().isEmpty) {
      final resposta = await _supabase
          .from('clientes')
          .select()
          .order('nome', ascending: true)
          .limit(20);
      return resposta.map((map) => Cliente.fromMap(map)).toList();
    }

    // 2. Limpa o termo digitado e prepara para a busca
    final termoLimpo = termo.trim();

    // Se o usuário digitou apenas números (ex: buscando telefone), limpamos formatações
    final termoNumerico = termoLimpo.replaceAll(RegExp(r'[^0-9]'), '');

    // 3. Monta a consulta inteligente combinando os campos com "OR"
    // O "%" significa que o texto pode ter qualquer coisa antes ou depois da palavra
    String filtroOr =
        'nome.ilike.%$termoLimpo%,'
        'rua.ilike.%$termoLimpo%,'
        'bairro.ilike.%$termoLimpo%';

    // Se o que foi digitado contiver números, adicionamos o telefone na busca
    if (termoNumerico.isNotEmpty) {
      filtroOr += ',telefone.ilike.%$termoNumerico%';
    }

    // 4. Executa a busca no Supabase
    final resposta = await _supabase
        .from('clientes')
        .select()
        .or(filtroOr)
        .order('nome', ascending: true)
        .limit(30); // Limite por segurança para não travar a tela

    // 5. Converte a resposta do banco de volta para os objetos Cliente Dart
    return resposta.map((map) => Cliente.fromMap(map)).toList();
  }
}
