import 'package:supabase_flutter/supabase_flutter.dart';
import '../Modelos/orcamento_model.dart';

class OrcamentoRepository {
  final _supabase = Supabase.instance.client;

  /// Busca orçamentos cruzando dados do cliente (Nome, Rua, Bairro) e filtrando por Data opcional.
  ///
  /// Retorna uma lista de [Orcamento], onde você também pode extrair os dados do cliente embutidos.
  Future<List<Orcamento>> buscarOrcamentosAvancado({
    String termoPesquisa = '',
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    // 1. Prepara a query base fazendo JOIN com a tabela 'clientes'
    // O modificador !inner é o segredo: ele força o banco a filtrar os orçamentos
    // baseado nas regras que vamos aplicar na tabela de clientes.
    var query = _supabase.from('orcamentos').select('''
          *,
          clientes!inner (
            id,
            nome,
            rua,
            bairro
          )
        ''');

    // 2. Aplica filtro de Data (se fornecido pelo usuário na tela)
    if (dataInicio != null) {
      query = query.gte('data_pega', dataInicio.toIso8601String());
    }
    if (dataFim != null) {
      // Ajusta para o final do dia (23:59:59)
      final fimDoDia = DateTime(
        dataFim.year,
        dataFim.month,
        dataFim.day,
        23,
        59,
        59,
      );
      query = query.lte('data_pega', fimDoDia.toIso8601String());
    }

    // 3. Aplica o filtro de Nome, Rua ou Bairro no cliente vinculado (se o usuário digitou algo)
    final termo = termoPesquisa.trim();
    if (termo.isNotEmpty) {
      // A sintaxe clientes.nome indica ao Supabase para aplicar o ILIKE na tabela relacional!
      query = query.or(
        'nome.ilike.%$termo%,rua.ilike.%$termo%,bairro.ilike.%$termo%',
        referencedTable: 'clientes',
      );
    }

    // 4. Ordena para trazer os Urgentes primeiro, depois os mais recentes, limitando a paginação
    final resposta = await query
        .order('eh_urgente', ascending: false)
        .order('data_pega', ascending: false)
        .limit(30);

    // 5. Mapeia a resposta JSON do Supabase para o seu modelo Dart
    return (resposta as List<dynamic>)
        .map((map) => Orcamento.fromMap(map as Map<String, dynamic>))
        .toList();
  }

  /// Inserção em Massa ou Unitária super rápida (Upsert)
  Future<void> salvarOrcamento(Orcamento orcamento) async {
    await _supabase.from('orcamentos').upsert(orcamento.toMap());
  }
}
