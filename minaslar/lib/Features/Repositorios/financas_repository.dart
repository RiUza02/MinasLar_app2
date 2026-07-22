import 'package:supabase_flutter/supabase_flutter.dart';
import '../Modelos/financas_model.dart';

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

  /// Busca os dados consolidados da tabela `financas` para a Dashboard
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

  /// Executa a RPC no Supabase para recalcular os últimos 6 meses
  Future<int> sincronizarFinancas() async {
    // Chama a função PostgreSQL criada no banco
    await _supabase.rpc('atualizar_financas_ultimos_6_meses');
    return 6;
  }
}
