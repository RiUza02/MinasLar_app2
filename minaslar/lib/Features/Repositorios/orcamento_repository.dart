import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../Modelos/orcamento_model.dart';
import '../../Pages/HomePage/lista_orcamento.dart';

/// Repositório responsável pela consulta, salvamento e filtros de orçamentos no Supabase.
class OrcamentoRepository {
  final _supabase = Supabase.instance.client;

  /// [uso]: Realiza buscas de orçamentos filtrando por texto do cliente (Nome, Rua, Bairro) e intervalo de datas.
  Future<List<Orcamento>> buscarOrcamentosAvancado({
    String termoPesquisa = '',
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    var query = _supabase.from('orcamentos').select('''
          *,
          clientes!cliente_id!inner (
            id,
            nome,
            rua,
            bairro
          )
        ''');

    if (dataInicio != null) {
      query = query.gte('data_pega', dataInicio.toUtc().toIso8601String());
    }

    if (dataFim != null) {
      final fimDoDia = DateTime(
        dataFim.year,
        dataFim.month,
        dataFim.day,
        23,
        59,
        59,
        999,
      ).toUtc();
      query = query.lte('data_pega', fimDoDia.toIso8601String());
    }

    final termo = termoPesquisa.trim();
    if (termo.isNotEmpty) {
      query = query.or(
        'nome.ilike.%$termo%,rua.ilike.%$termo%,bairro.ilike.%$termo%',
        referencedTable: 'clientes',
      );
    }

    final resposta = await query
        .order('eh_urgente', ascending: false)
        .order('data_pega', ascending: false)
        .limit(30);

    return (resposta as List<dynamic>)
        .map((map) => Orcamento.fromMap(map as Map<String, dynamic>))
        .toList();
  }

  /// [uso]: Busca uma lista paginada de orçamentos com suporte a busca múltipla combinada e ordenação avançada.
  Future<List<Orcamento>> buscarOrcamentosPaginados({
    required int page,
    required int pageSize,
    String termo = '',
    required OrcamentoSortColumn sortColumn,
    required bool ascending,
  }) async {
    final offset = (page - 1) * pageSize;

    String dbColumn = 'data_pega';
    bool nullsFirst = false;

    switch (sortColumn) {
      case OrcamentoSortColumn.valor:
        dbColumn = 'valor';
        nullsFirst = false;
        break;
      case OrcamentoSortColumn.status:
        dbColumn = 'entregue';
        break;
      case OrcamentoSortColumn.dataRecente:
        dbColumn = 'data_pega';
        break;
    }

    // 1. Query base com chave estrangeira explícita
    var query = _supabase
        .from('orcamentos')
        .select('*, clientes!cliente_id!inner(*)');

    // 2. Busca Múltipla Combinada (Filtro por espaço ou vírgula)
    final termoBusca = termo.trim();
    if (termoBusca.isNotEmpty) {
      final termos = termoBusca
          .split(RegExp(r'[,/\s]+')) // Aceita espaços ou vírgulas
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty);

      for (final termoIndividual in termos) {
        List<String> orConditions = [];

        // 2.1 Nome do cliente
        orConditions.add('clientes.nome.ilike.%$termoIndividual%');

        // 2.2 Valor exato (faixa inteira ignora centavos)
        final valorNumerico = int.tryParse(termoIndividual);
        if (valorNumerico != null) {
          orConditions.add(
            'and(valor.gte.$valorNumerico,valor.lt.${valorNumerico + 1})',
          );
        }

        // 2.3 Data (formato brasileiro dd/mm/yy ou dd/mm/yyyy)
        try {
          final formatters = [
            DateFormat('d/M/y'),
            DateFormat('d/M/yyyy'),
            DateFormat('yyyy'),
          ];
          DateTime? dataParsed;
          for (var f in formatters) {
            try {
              dataParsed = f.parseLoose(termoIndividual);
              break;
            } catch (_) {}
          }

          if (dataParsed != null) {
            final inicioDia = DateTime.utc(
              dataParsed.year,
              dataParsed.month,
              dataParsed.day,
            ).toIso8601String();
            final fimDia = DateTime.utc(
              dataParsed.year,
              dataParsed.month,
              dataParsed.day,
              23,
              59,
              59,
            ).toIso8601String();

            orConditions.add(
              'and(data_pega.gte.$inicioDia,data_pega.lte.$fimDia)',
            );
            orConditions.add(
              'and(data_entrega.gte.$inicioDia,data_entrega.lte.$fimDia)',
            );
          }
        } catch (_) {}

        if (orConditions.isNotEmpty) {
          query = query.or(orConditions.join(','));
        }
      }
    }

    // 3. Ordenação no Banco de Dados
    dynamic queryOrdenada;
    if (sortColumn == OrcamentoSortColumn.status) {
      queryOrdenada = query
          .order('entregue', ascending: true)
          .order('eh_urgente', ascending: false)
          .order('data_entrega', ascending: true, nullsFirst: false);
    } else {
      queryOrdenada = query.order(
        dbColumn,
        ascending: ascending,
        nullsFirst: nullsFirst,
      );
    }

    final response = await queryOrdenada.range(offset, offset + pageSize - 1);
    final lista = (response as List)
        .map((map) => Orcamento.fromMap(map as Map<String, dynamic>))
        .toList();

    // 4. Aplicação das Regras de Negócio Rigorosas (In-Memory Sort)
    _aplicarOrdenacaoRigorosa(lista, sortColumn, ascending);

    return lista;
  }

  // --- MÉTODOS AUXILIARES DE ORDENAÇÃO RIGOROSA ---

  void _aplicarOrdenacaoRigorosa(
    List<Orcamento> lista,
    OrcamentoSortColumn sortColumn,
    bool ascending,
  ) {
    switch (sortColumn) {
      case OrcamentoSortColumn.status:
        lista.sort((a, b) {
          final pA = _getPrioridadeStatus(a);
          final pB = _getPrioridadeStatus(b);
          final comp = pA.compareTo(pB);
          if (comp != 0) {
            return ascending ? comp : -comp;
          }
          return _getDataPega(b).compareTo(_getDataPega(a));
        });
        break;
      case OrcamentoSortColumn.valor:
        lista.sort((a, b) {
          final valA = _getValorMapeado(a);
          final valB = _getValorMapeado(b);
          if (valA == -1.0 && valB == -1.0) return 0;
          if (valA == -1.0) return 1;
          if (valB == -1.0) return -1;
          return ascending ? valA.compareTo(valB) : valB.compareTo(valA);
        });
        break;
      case OrcamentoSortColumn.dataRecente:
        lista.sort((a, b) => _getDataPega(b).compareTo(_getDataPega(a)));
        break;
    }
  }

  /// Calcula a prioridade exata de 1 a 6 para ordenação.
  int _getPrioridadeStatus(Orcamento o) {
    final map = o.toMap();

    // 5º: Entregue (Concluído)
    if (map['entregue'] == true) return 5;

    // --- A partir daqui, APENAS orçamentos NÃO entregues ---

    // 1º: Urgente, não entregue, retorno ou não
    if (map['eh_urgente'] == true) return 1;

    final dataEntregaStr = map['data_entrega']?.toString();
    DateTime? dataEntrega;
    if (dataEntregaStr != null &&
        dataEntregaStr.isNotEmpty &&
        dataEntregaStr != 'null') {
      dataEntrega = DateTime.tryParse(dataEntregaStr);
    }

    final hoje = DateTime.now();
    final hojeOnly = DateTime(hoje.year, hoje.month, hoje.day);

    DateTime? dataEntregaOnly;
    if (dataEntrega != null) {
      final local = dataEntrega.toLocal();
      dataEntregaOnly = DateTime(local.year, local.month, local.day);
    }

    final isAtrasado =
        dataEntregaOnly != null && dataEntregaOnly.isBefore(hojeOnly);

    // 2º: Atrasado, não entregue, retorno ou não
    if (isAtrasado) return 2;

    // 3º: Retorno, não entregue
    if (map['eh_retorno'] == true) return 3;

    // 4º: Em prazo (data de entrega superior ou igual a hoje)
    if (dataEntregaOnly != null) return 4;

    // 6º: Sem data
    return 6;
  }

  double _getValorMapeado(Orcamento o) {
    final val = o.toMap()['valor'];
    if (val == null) return -1.0;
    final numVal = (val is num)
        ? val.toDouble()
        : (double.tryParse(val.toString()) ?? 0.0);
    return numVal <= 0 ? -1.0 : numVal;
  }

  DateTime _getDataPega(Orcamento o) {
    final str = o.toMap()['data_pega']?.toString();
    return str != null
        ? (DateTime.tryParse(str) ?? DateTime.now())
        : DateTime.now();
  }

  /// [uso]: Salva ou atualiza um orçamento no banco, injetando automaticamente o ID do usuário autenticado.
  Future<void> salvarOrcamento(Orcamento orcamento) async {
    final dadosParaSalvar = orcamento.toMap();

    final authUserId = _supabase.auth.currentUser?.id;
    if (authUserId != null) {
      dadosParaSalvar['user_id'] = authUserId;
    }

    await _supabase.from('orcamentos').upsert(dadosParaSalvar);
  }

  /// [uso]: Busca um orçamento único por seu ID, incluindo os dados do cliente.
  Future<Orcamento> buscarOrcamentoPorId(String orcamentoId) async {
    final data = await _supabase
        .from('orcamentos')
        .select('*, clientes!cliente_id(*)')
        .eq('id', orcamentoId)
        .single();

    return Orcamento.fromMap(data);
  }

  /// [uso]: Exclui um orçamento do banco de dados.
  Future<void> excluirOrcamento(String orcamentoId) async {
    await _supabase.from('orcamentos').delete().eq('id', orcamentoId);
  }

  /// [uso]: Busca orçamentos pendentes com entrada ou entrega agendada para o dia atual.
  Future<List<Map<String, dynamic>>> buscarOrcamentosDoDia() async {
    final hoje = DateTime.now();

    final inicioDoDia = DateTime(hoje.year, hoje.month, hoje.day);
    final fimDoDia = DateTime(hoje.year, hoje.month, hoje.day, 23, 59, 59, 999);

    final filtroEntrada =
        'data_pega.gte.${inicioDoDia.toIso8601String()},data_pega.lte.${fimDoDia.toIso8601String()}';
    final filtroEntrega =
        'data_entrega.gte.${inicioDoDia.toIso8601String()},data_entrega.lte.${fimDoDia.toIso8601String()}';

    final response = await _supabase
        .from('orcamentos')
        .select(
          '*, clientes!cliente_id(nome, telefone, bairro, rua, numero, complemento)',
        )
        .eq('entregue', false)
        .or('and($filtroEntrada),and($filtroEntrega)')
        .order('horario_do_dia', ascending: true)
        .order('eh_urgente', ascending: false)
        .order('data_pega', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Busca o histórico de orçamentos de um cliente específico.
  Future<List<Map<String, dynamic>>> buscarHistoricoPorCliente(
    String clienteId,
  ) async {
    final response = await _supabase
        .from('orcamentos')
        .select()
        .eq('cliente_id', clienteId)
        .order('data_pega', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }
}
