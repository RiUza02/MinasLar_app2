import 'package:supabase_flutter/supabase_flutter.dart';
import '../Modelos/orcamento_model.dart';

/// Repositório responsável pela consulta, salvamento e filtros de orçamentos no Supabase.
class OrcamentoRepository {
  final _supabase = Supabase.instance.client;

  /// [uso]: Realiza buscas de orçamentos filtrando por texto do cliente (Nome, Rua, Bairro) e intervalo de datas.
  Future<List<Orcamento>> buscarOrcamentosAvancado({
    String termoPesquisa = '',
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    // Busca orçamentos cruzando dados da tabela de clientes via INNER JOIN
    var query = _supabase.from('orcamentos').select('''
          *,
          clientes!cliente_id!inner (
            id,
            nome,
            rua,
            bairro
          )
        ''');

    // Filtra pela data inicial convertida para UTC
    if (dataInicio != null) {
      query = query.gte('data_pega', dataInicio.toUtc().toIso8601String());
    }

    // Filtra pela data final considerando o fim do dia em UTC (23:59:59)
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

    // Filtra por termo de busca nos campos da tabela relacional de clientes
    final termo = termoPesquisa.trim();
    if (termo.isNotEmpty) {
      query = query.or(
        'nome.ilike.%$termo%,rua.ilike.%$termo%,bairro.ilike.%$termo%',
        referencedTable: 'clientes',
      );
    }

    // Ordena por urgência e data, limitando a 30 resultados
    final resposta = await query
        .order('eh_urgente', ascending: false)
        .order('data_pega', ascending: false)
        .limit(30);

    // Mapeia a resposta do banco para objetos Orcamento
    return (resposta as List<dynamic>)
        .map((map) => Orcamento.fromMap(map as Map<String, dynamic>))
        .toList();
  }

  /// [uso]: Salva ou atualiza um orçamento no banco, injetando automaticamente o ID do usuário autenticado.
  Future<void> salvarOrcamento(Orcamento orcamento) async {
    final dadosParaSalvar = orcamento.toMap();

    // Adiciona o ID do usuário autenticado para respeitar as regras de RLS
    final authUserId = _supabase.auth.currentUser?.id;
    if (authUserId != null) {
      dadosParaSalvar['user_id'] = authUserId;
    }

    await _supabase.from('orcamentos').upsert(dadosParaSalvar);
  }

  /// [uso]: Busca orçamentos pendentes com entrada ou entrega agendada para o dia atual.
  Future<List<Map<String, dynamic>>> buscarOrcamentosDoDia() async {
    final hoje = DateTime.now();

    // Define o intervalo do dia atual (00:00:00 até 23:59:59)
    final inicioDoDia = DateTime(hoje.year, hoje.month, hoje.day);
    final fimDoDia = DateTime(hoje.year, hoje.month, hoje.day, 23, 59, 59, 999);

    // Prepara os filtros de intervalo para data de entrada e data de entrega
    final filtroEntrada =
        'data_pega.gte.${inicioDoDia.toIso8601String()},data_pega.lte.${fimDoDia.toIso8601String()}';
    final filtroEntrega =
        'data_entrega.gte.${inicioDoDia.toIso8601String()},data_entrega.lte.${fimDoDia.toIso8601String()}';

    // Consulta orçamentos não entregues, ordenando por horário, urgência e data
    final response = await _supabase
        .from('orcamentos')
        .select(
          // CORRIGIDO: substituído 'apartamento' por 'complemento'
          '*, clientes!cliente_id(nome, telefone, bairro, rua, numero, complemento)',
        )
        .eq('entregue', false)
        .or('and($filtroEntrada),and($filtroEntrega)')
        .order('horario_do_dia', ascending: true)
        .order('eh_urgente', ascending: false)
        .order('data_pega', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }
}
