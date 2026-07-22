import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../Pages/HomePage/lista_cliente.dart';
import '../Modelos/cliente_model.dart';

// **[Propósito]** Repositório responsável pelas consultas, paginações, buscas dinâmicas e persistência de clientes no Supabase.
// **[Como usar]** final clienteRepo = ClienteRepository(); / await clienteRepo.salvarCliente(novoCliente);
class ClienteRepository {
  final _supabase = Supabase.instance.client;

  // **[Propósito]** Realiza a busca paginada de clientes aplicável com filtros múltiplos (nome, endereço, telefone) e ordenação no banco.
  // **[Parâmetros]** page (int) -> Número da página (base 1); pageSize (int) -> Quantidade de registros por página; termo (String) -> Filtro de pesquisa; sortColumn (ClienteSortColumn) -> Coluna de ordenação; ascending (bool) -> Direção da ordenação.
  // **[Retorno]** Future<List<Cliente>> -> Lista de clientes retornados e serializados do Supabase.
  Future<List<Cliente>> buscarClientesPaginados({
    required int page,
    required int pageSize,
    String termo = '',
    required ClienteSortColumn sortColumn,
    required bool ascending,
  }) async {
    final offset = (page - 1) * pageSize;

    // Mapeamento das colunas da tabela do Supabase de acordo com a seleção da UI.
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

    // Montagem da query de busca dinâmica multicampos para o Supabase.
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
      // Consulta principal associando dados de relatórios e ordens de serviços com JOIN.
      dynamic query = _supabase
          .from('clientes')
          .select('*, orcamentos!ultimo_orcamento_id(data_pega)');

      if (filtroQuery != null) query = query.or(filtroQuery);

      final response = await query
          .order(dbColumn, ascending: ascending)
          .range(offset, offset + pageSize - 1);

      return (response as List).map((map) => Cliente.fromMap(map)).toList();
    } catch (_) {
      // Fallback defensivo: caso falhe a junção com 'orcamentos', realiza a busca simples apenas em 'clientes'.
      dynamic queryFallback = _supabase.from('clientes').select();

      if (filtroQuery != null) queryFallback = queryFallback.or(filtroQuery);

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

  // **[Propósito]** Busca um cliente específico pelo seu ID (UUID) no Supabase, com suporte a fallback de JOIN.
  // **[Parâmetros]** id (String) -> Identificador único do cliente no banco.
  // **[Retorno]** Future<Map<String, dynamic>?> -> Registro bruto do cliente ou nulo caso não encontrado.
  Future<Map<String, dynamic>?> buscarClientePorId(String id) async {
    try {
      final response = await _supabase
          .from('clientes')
          .select('*, orcamentos!ultimo_orcamento_id(data_pega)')
          .eq('id', id)
          .maybeSingle();
      return response;
    } catch (_) {
      // Fallback para caso a relação da tabela de orçamentos esteja indisponível.
      final response = await _supabase
          .from('clientes')
          .select()
          .eq('id', id)
          .maybeSingle();
      return response;
    }
  }

  // **[Propósito]** Remove o registro de um cliente do banco de dados a partir do seu ID.
  // **[Parâmetros]** id (String) -> Identificador único do cliente a ser removido.
  Future<void> excluirCliente(String id) async {
    await _supabase.from('clientes').delete().eq('id', id);
  }

  // **[Propósito]** Consulta se já existe um cliente cadastrado com dados similares de nome e endereço para evitar duplicidades.
  // **[Parâmetros]** nome (String) -> Nome do cliente; rua (String) -> Logradouro; numero (String) -> Número do imóvel.
  // **[Retorno]** Future<Cliente?> -> Retorna a instância do cliente existente se houver correspondência, ou nulo.
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

  // **[Propósito]** Insere os dados de um novo cliente no banco de dados Supabase.
  // **[Parâmetros]** cliente (Cliente) -> Entidade preenchida com os dados cadastrais do cliente.
  Future<void> salvarCliente(Cliente cliente) async {
    await _supabase.from('clientes').insert(cliente.toMap());
  }

  // **[Propósito]** Atualiza campos específicos de um cliente cadastrado existente no banco.
  // **[Parâmetros]** id (String) -> Identificador único do cliente; dadosAtualizados (Map<String, dynamic>) -> Mapa contendo as colunas e os novos valores.
  Future<void> atualizarCliente(
    String id,
    Map<String, dynamic> dadosAtualizados,
  ) async {
    await _supabase.from('clientes').update(dadosAtualizados).eq('id', id);
  }
}
