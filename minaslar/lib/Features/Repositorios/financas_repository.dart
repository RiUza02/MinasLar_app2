import 'package:supabase_flutter/supabase_flutter.dart';
import '../Modelos/financas_model.dart';

// **[Propósito]** Repositório responsável por buscar, formatar e processar os dados consolidados de finanças para exibição em gráficos e painéis da Dashboard.
// **[Como usar]** final processador = ProcessaOrcamentos(); / final dados = await processador.buscarDadosDashboard();
class ProcessaOrcamentos {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const List<String> _mesesSiglas = [
    'JAN',
    'FEV',
    'MAR',
    'ABR',
    'MAI',
    'JUN',
    'JUL',
    'AGO',
    'SET',
    'OUT',
    'NOV',
    'DEZ',
  ];

  // **[Propósito]** Busca os dados financeiros dos últimos 6 meses e estrutura os mapeamentos específicos necessários para renderizar os gráficos de faturamento, barras e distribuição por turnos.
  // **[Retorno]** Future<Map<String, dynamic>> -> Mapa contendo a instância financeira do mês atual e as listas estruturadas para os gráficos.
  Future<Map<String, dynamic>> buscarDadosDashboard() async {
    // 1. Busca os dados dos últimos 6 meses no banco
    final response = await _supabase
        .from('financas')
        .select()
        .order('ano', ascending: false)
        .order('mes', ascending: false)
        .limit(6);

    final listaFinancas = (response as List)
        .map((item) => Financas.fromMap(item))
        .toList();

    // Inverte para exibir ordem cronológica nos gráficos (do mês mais antigo para o mais recente)
    final listaCronologica = listaFinancas.reversed.toList();

    // 2. Identifica as métricas do mês atual
    final agora = DateTime.now();
    final financaMesAtual = listaFinancas.firstWhere(
      (f) => f.mes == agora.month && f.ano == agora.year,
      orElse: () => listaFinancas.isNotEmpty
          ? listaFinancas.first
          : const Financas(mes: 0, ano: 0),
    );

    // 3. Monta o gráfico de faturamento de linhas
    final graficoFaturamento = listaCronologica.map((f) {
      return {'month': _mesesSiglas[f.mes - 1], 'value': f.faturamento};
    }).toList();

    // 4. Monta o gráfico de barras (Visão Geral)
    final graficoBarras = listaCronologica.map((f) {
      return {
        'month': _mesesSiglas[f.mes - 1],
        'orcamentos': f.orcamentosEntregues,
        'clientes': f.novosClientes,
        'retornos': f.orcamentosRetorno,
      };
    }).toList();

    // 5. Monta a distribuição por turnos (mês atual)
    final turnos = {
      'Manhã': financaMesAtual.servicosManha,
      'Tarde': financaMesAtual.servicosTarde,
    };

    return {
      'financaMesAtual':
          financaMesAtual, // Envia o modelo completo com todos os contadores do mês
      'faturamentoMesAtual': financaMesAtual.faturamento,
      'graficoFaturamento': graficoFaturamento,
      'turnos': turnos,
      'graficoBarras': graficoBarras,
    };
  }

  // **[Propósito]** Aciona uma procedure (RPC) diretamente no PostgreSQL do Supabase para recalcular e sincronizar os agregados financeiros dos últimos 6 meses.
  // **[Retorno]** Future<int> -> Retorna o número estático representativo da quantidade de meses processados.
  Future<int> sincronizarFinancas() async {
    // Chama a função PostgreSQL criada no banco
    await _supabase.rpc('atualizar_financas_ultimos_6_meses');
    return 6;
  }
}
