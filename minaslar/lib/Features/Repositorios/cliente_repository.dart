import 'package:supabase_flutter/supabase_flutter.dart';
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
}
