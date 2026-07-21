import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../Modelos/cliente_model.dart';
import '../../Pages/HomePage/lista_cliente.dart';

/// Repositório responsável pela consulta e manipulação de dados de clientes no Supabase.
class ClienteRepository {
  final _supabase = Supabase.instance.client;

  /// [uso]: Busca uma lista paginada de clientes com suporte a múltiplos filtros de busca e ordenação dinâmica no banco.
  Future<List<Cliente>> buscarClientesPaginados({
    required int page,
    required int pageSize,
    String termo = '',
    required ClienteSortColumn sortColumn,
    required bool ascending,
  }) async {
    final offset = (page - 1) * pageSize;

    // 1. Mapeia a coluna de ordenação desejada
    String dbColumn;
    switch (sortColumn) {
      case ClienteSortColumn.nome:
        dbColumn = 'nome';
        break;
      case ClienteSortColumn.rua:
        dbColumn = 'rua';
        break;
      case ClienteSortColumn.bairro:
        dbColumn = 'bairro';
        break;
      case ClienteSortColumn.ultimoAtendimento:
        dbColumn = 'orcamentos(data_pega)';
        break;
    }

    // 2. Monta a string de filtro multicampos (se houver termo de busca)
    String? filtroQuery;
    if (termo.trim().isNotEmpty) {
      final termosDeBusca = termo
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty);

      for (final termoIndividual in termosDeBusca) {
        final termoNumerico = termoIndividual.replaceAll(RegExp(r'[^0-9]'), '');
        String filtroAtual =
            'nome.ilike.%$termoIndividual%,rua.ilike.%$termoIndividual%,bairro.ilike.%$termoIndividual%';

        if (termoNumerico.isNotEmpty) {
          filtroAtual += ',telefone.ilike.%$termoNumerico%';
        }
        filtroQuery = filtroQuery == null
            ? filtroAtual
            : '$filtroQuery,$filtroAtual';
      }
    }

    try {
      // TENTATIVA PRINCIPAL: Busca clientes fazendo JOIN com a tabela de orçamentos
      dynamic query = _supabase
          .from('clientes')
          .select('*, orcamentos!ultimo_orcamento_id(data_pega)');

      if (filtroQuery != null) query = query.or(filtroQuery);

      final response = await query
          .order(dbColumn, ascending: ascending)
          .range(offset, offset + pageSize - 1);

      return (response as List).map((map) => Cliente.fromMap(map)).toList();
    } catch (_) {
      // FALLBACK DEFENSIVO: Se a tabela orcamentos não existir ou a relação falhar,
      // busca apenas na tabela clientes para que a lista continue aparecendo normalmente.
      dynamic queryFallback = _supabase.from('clientes').select();

      if (filtroQuery != null) queryFallback = queryFallback.or(filtroQuery);

      // Se a ordenação era por atendimento (que depende da tabela orcamentos),
      // mudamos a ordenação para 'criado_em' ou 'nome' para evitar erro no banco.
      final colunaSegura = (sortColumn == ClienteSortColumn.ultimoAtendimento)
          ? 'criado_em'
          : dbColumn;

      final responseFallback = await queryFallback
          .order(colunaSegura, ascending: ascending)
          .range(offset, offset + pageSize - 1);

      return (responseFallback as List)
          .map((map) => Cliente.fromMap(map))
          .toList();
    }
  }

  /// Busca um cliente único por seu ID, com fallback para consulta sem JOIN.
  Future<Map<String, dynamic>?> buscarClientePorId(String id) async {
    try {
      // Tenta buscar mantendo o padrão com JOIN do último orçamento
      final response = await _supabase
          .from('clientes')
          .select('*, orcamentos!ultimo_orcamento_id(data_pega)')
          .eq('id', id)
          .maybeSingle();
      return response;
    } catch (_) {
      // Fallback caso a relação/tabela orcamentos ainda não exista
      final response = await _supabase
          .from('clientes')
          .select()
          .eq('id', id)
          .maybeSingle();
      return response;
    }
  }

  /// Exclui um cliente do banco de dados pelo seu ID.
  Future<void> excluirCliente(String id) async {
    await _supabase.from('clientes').delete().eq('id', id);
  }

  /// Verifica no banco se já existe um cliente com nome e endereço semelhantes.
  Future<Cliente?> verificarDuplicado({
    required String nome,
    required String rua,
    required String numero,
  }) async {
    if (nome.trim().isEmpty || rua.trim().isEmpty || numero.trim().isEmpty) {
      return null;
    }

    final primeiroNome = nome.trim().split(' ').first;

    try {
      final response = await _supabase
          .from('clientes')
          .select()
          .ilike('nome', '$primeiroNome%')
          .ilike('rua', '%${rua.trim()}%')
          .eq('numero', numero.trim())
          .limit(1)
          .maybeSingle();

      if (response != null) {
        return Cliente.fromMap(response);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Erro ao verificar cliente duplicado: $e");
      }
      return null;
    }
  }

  /// Insere um novo cliente no banco de dados.
  Future<void> salvarCliente(Cliente cliente) async {
    await _supabase.from('clientes').insert(cliente.toMap());
  }

  /// Atualiza os dados de um cliente existente no banco de dados.
  Future<void> atualizarCliente(
    String id,
    Map<String, dynamic> dadosAtualizados,
  ) async {
    await _supabase.from('clientes').update(dadosAtualizados).eq('id', id);
  }
}
