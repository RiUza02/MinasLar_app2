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
    var query = _supabase.from('orcamentos').select('''
          *,
          clientes!inner (
            id,
            nome,
            rua,
            bairro
          )
        ''');

    // 2. Aplica filtro de Data (com conversão para UTC para evitar cortes de fuso horário)
    if (dataInicio != null) {
      query = query.gte('data_pega', dataInicio.toUtc().toIso8601String());
    }
    if (dataFim != null) {
      // Ajusta para o final do dia local (23:59:59) e converte para UTC
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

    // 3. Aplica o filtro de Nome, Rua ou Bairro no cliente vinculado
    final termo = termoPesquisa.trim();
    if (termo.isNotEmpty) {
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

  /// Injeta o ID do usuário logado diretamente no mapa antes de enviar ao banco.
  Future<void> salvarOrcamento(Orcamento orcamento) async {
    final dadosParaSalvar = orcamento.toMap();

    // Injeta o ID de autenticação se houver um usuário logado (evita bloqueio por RLS)
    final authUserId = _supabase.auth.currentUser?.id;
    if (authUserId != null) {
      dadosParaSalvar['user_id'] = authUserId;
    }

    await _supabase.from('orcamentos').upsert(dadosParaSalvar);
  }

  /// Busca os orçamentos com data de entrada ou entrega agendada para hoje.
  Future<List<Map<String, dynamic>>> buscarOrcamentosDoDia() async {
    final hoje = DateTime.now();
    // Define o intervalo de hoje de forma robusta, da meia-noite local de hoje
    // até o último milissegundo do dia.
    final inicioDoDia = DateTime(hoje.year, hoje.month, hoje.day);
    final fimDoDia = DateTime(hoje.year, hoje.month, hoje.day, 23, 59, 59, 999);

    // A conversão para toIso8601String() em um DateTime local já inclui
    // o fuso horário, garantindo que o Supabase interprete o intervalo corretamente.
    final filtroEntrada =
        'data_pega.gte.${inicioDoDia.toIso8601String()},data_pega.lte.${fimDoDia.toIso8601String()}';
    final filtroEntrega =
        'data_entrega.gte.${inicioDoDia.toIso8601String()},data_entrega.lte.${fimDoDia.toIso8601String()}';

    final response = await _supabase
        .from('orcamentos')
        .select('*, clientes(nome, telefone, bairro, rua, numero, apartamento)')
        .eq(
          'entregue',
          false,
        ) // Garante que apenas orçamentos pendentes apareçam.
        .or('and($filtroEntrada),and($filtroEntrega)')
        .order('horario_do_dia', ascending: true) // 1. Manhã primeiro
        .order(
          'eh_urgente',
          ascending: false,
        ) // 2. Urgentes primeiro dentro de cada turno
        .order(
          'data_pega',
          ascending: true,
        ); // 3. Desempate por data de criação

    return List<Map<String, dynamic>>.from(response);
  }
}
