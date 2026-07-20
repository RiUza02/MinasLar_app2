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

    // Busca clientes e inclui a data do orçamento via JOIN relacional
    dynamic query = _supabase
        .from('clientes')
        .select('*, orcamentos!ultimo_orcamento_id(data_pega)');

    // Aplica filtro multicampos (Nome, Rua, Bairro e Telefone)
    if (termo.trim().isNotEmpty) {
      final termosDeBusca = termo
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty);

      for (final termoIndividual in termosDeBusca) {
        final termoNumerico = termoIndividual.replaceAll(RegExp(r'[^0-9]'), '');
        String filtroOr =
            'nome.ilike.%$termoIndividual%,rua.ilike.%$termoIndividual%,bairro.ilike.%$termoIndividual%';

        // Inclui busca por telefone apenas se houver números no termo
        if (termoNumerico.isNotEmpty) {
          filtroOr += ',telefone.ilike.%$termoNumerico%';
        }
        query = query.or(filtroOr);
      }
    }

    // Mapeia a coluna do banco de dados para ordenação
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
        // Ordena pela data do orçamento na tabela vinculada pelo JOIN
        dbColumn = 'orcamentos(data_pega)';
        break;
    }

    // Executa a consulta aplicando a ordenação e os limites de página
    final response = await query
        .order(dbColumn, ascending: ascending)
        .range(offset, offset + pageSize - 1);

    // Mapeia a resposta em objetos Cliente
    return (response as List).map((map) => Cliente.fromMap(map)).toList();
  }
}
