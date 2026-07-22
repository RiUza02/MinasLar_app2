import 'package:fl_chart/fl_chart.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../../../Core/Design/design_system.dart';
import '../../../Core/Errors/errors.dart';
import '../../../Core/Widgets/widgets.dart';
import '../../Features/Modelos/financas_model.dart';
import '../../../Features/Repositorios/financas_repository.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Estados de controle
  bool _isLoading = true;
  bool _isSyncing = false;
  String? _error;

  // Repositório
  final ProcessaOrcamentos _repo = ProcessaOrcamentos();

  // Métricas do Mês Atual
  double _faturamentoMesAtual = 0;
  int _orcamentosEntregues = 0;
  int _novosClientes = 0;
  int _orcamentosRetorno = 0;
  int _orcamentosUrgentes = 0;
  int _servicosManha = 0;
  int _servicosTarde = 0;
  int _clientesProblematicos = 0;

  // Dados dos Gráficos (Histórico)
  List<Map<String, dynamic>> _faturamento6Meses = [];
  List<Map<String, dynamic>> _stats6Meses = [];
  Map<String, int> _servicosPorTurno = {'Manhã': 0, 'Tarde': 0};

  // Cores
  final Color _corOrcamentos = AppColors.primary;
  final Color _corClientes = AppColors.success;
  final Color _corRetornos = AppColors.warning;

  // Getters para cálculos em tempo real
  double get _faturamentoTotal6Meses {
    return _faturamento6Meses.fold(
      0.0,
      (sum, item) => sum + ((item['value'] as num?)?.toDouble() ?? 0.0),
    );
  }

  double get _taxaRetornoPercentual {
    if (_orcamentosEntregues == 0) return 0.0;
    return (_orcamentosRetorno / _orcamentosEntregues) * 100;
  }

  double get _taxaProblematicosVsNovosPercentual {
    if (_novosClientes == 0) return 0.0;
    return (_clientesProblematicos / _novosClientes) * 100;
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null).then((_) {
      _carregarDados();
    });
  }

  Future<void> _carregarDados() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dados = await _repo.buscarDadosDashboard();
      if (mounted) {
        final Financas? financaAtual = dados['financaMesAtual'] as Financas?;

        setState(() {
          _faturamentoMesAtual = (dados['faturamentoMesAtual'] ?? 0.0)
              .toDouble();
          _faturamento6Meses = List<Map<String, dynamic>>.from(
            dados['graficoFaturamento'] ?? [],
          );
          _servicosPorTurno = Map<String, int>.from(
            dados['turnos'] ?? {'Manhã': 0, 'Tarde': 0},
          );
          _stats6Meses = List<Map<String, dynamic>>.from(
            dados['graficoBarras'] ?? [],
          );

          if (financaAtual != null) {
            _orcamentosEntregues = financaAtual.orcamentosEntregues;
            _novosClientes = financaAtual.novosClientes;
            _orcamentosRetorno = financaAtual.orcamentosRetorno;
            _orcamentosUrgentes = financaAtual.orcamentosUrgentes;
            _servicosManha = financaAtual.servicosManha;
            _servicosTarde = financaAtual.servicosTarde;
            _clientesProblematicos = financaAtual.clientesProblematicos;
          } else {
            _servicosManha = _servicosPorTurno['Manhã'] ?? 0;
            _servicosTarde = _servicosPorTurno['Tarde'] ?? 0;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        _error = ErrorHandler.mapearErro(e);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sincronizarDashboard() async {
    if (!mounted || _isSyncing) return;
    setState(() => _isSyncing = true);

    try {
      final mesesAtualizados = await _repo.sincronizarFinancas();
      if (mounted) {
        if (mesesAtualizados > 0) {
          AppFeedback.show(
            context,
            '$mesesAtualizados ${mesesAtualizados == 1 ? 'mês foi atualizado' : 'meses foram atualizados'}.',
            type: FeedbackType.success,
          );
          await _carregarDados();
        } else {
          AppFeedback.show(context, 'Seus dados já estão sincronizados!');
        }
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.show(
          context,
          ErrorHandler.mapearErro(e),
          type: FeedbackType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  void _abrirListaClientesProblematicos() {
    AppFeedback.show(
      context,
      'Redirecionando para a lista de clientes problemáticos...',
      type: FeedbackType.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.background,

      floatingActionButton: FloatingActionButton(
        heroTag: 'btnSyncDashboard',
        onPressed: _sincronizarDashboard,
        backgroundColor: AppColors.primaryAlternative,
        foregroundColor: AppColors.textPrimary,
        child: _isSyncing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.textPrimary,
                  strokeWidth: 2.5,
                ),
              )
            : const Icon(AppIcons.atualizar),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryAlternative),
      );
    }

    if (_error != null) {
      return AppErrorView(
        message: _error!,
        buttonText: 'Tentar Novamente',
        onTryAgain: _carregarDados,
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarDados,
      color: AppColors.primaryAlternative,
      backgroundColor: AppColors.cardBackground,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppDimensions.spaceLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Painel de Visão Geral Finanças (Card Principal 6 Meses + Linhas)
            _buildFaturamento6MesesCard(),
            const SizedBox(height: AppDimensions.spaceXLarge),

            // 2. Métricas Mensais de Orçamentos (Cards / KPIs)
            _buildSecaoOrcamentos(),
            const SizedBox(height: AppDimensions.spaceXLarge),

            // 3. Métricas de Clientes (Cards Informativos)
            _buildSecaoClientes(),
            const SizedBox(height: AppDimensions.spaceXLarge),

            // 4. Operacional e Atendimentos (Turnos Manhã vs. Tarde)
            _buildSecaoOperacional(),
            const SizedBox(height: AppDimensions.spaceXLarge),

            // 5. Visão Geral Comparativa (Gráfico de Barras)
            _buildBarChart(),
            const SizedBox(height: AppDimensions.spaceXXXLarge),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. PAINEL DE VISÃO GERAL FINANÇAS
  // ===========================================================================
  Widget _buildFaturamento6MesesCard() {
    final totalFormatado = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    ).format(_faturamentoTotal6Meses);

    final mesAtualFormatado = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    ).format(_faturamentoMesAtual);

    return AppCardContainer(
      titulo: 'FATURAMENTO (6 MESES)',
      icone: AppIcons.valor,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Acumulado (6M)',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  totalFormatado,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontSize: 28,
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              child: Text(
                'Mês Atual: $mesAtualFormatado',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spaceLarge),
        SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (spot) =>
                      AppColors.cardBackground.withValues(alpha: 0.9),
                  getTooltipItems: (spots) => spots.map((spot) {
                    return LineTooltipItem(
                      NumberFormat.currency(
                        locale: 'pt_BR',
                        symbol: 'R\$ ',
                      ).format(spot.y),
                      AppTextStyles.bodyMediumBold,
                    );
                  }).toList(),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) =>
                    const FlLine(color: AppColors.borderLight, strokeWidth: 1),
              ),
              titlesData: _buildChartTitles(
                bottomTitles: _faturamento6Meses
                    .map((d) => d['month'] as String)
                    .toList(),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: _faturamento6Meses.asMap().entries.map((entry) {
                    return FlSpot(
                      entry.key.toDouble(),
                      (entry.value['value'] as num).toDouble(),
                    );
                  }).toList(),
                  isCurved: true,
                  color: AppColors.success,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.success.withValues(alpha: 0.3),
                        AppColors.success.withValues(alpha: 0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 2. MÉTRICAS MENSAIS DE ORÇAMENTOS
  // ===========================================================================
  Widget _buildSecaoOrcamentos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ORÇAMENTOS DO ÚLTIMO MÊS',
          style: AppTextStyles.bodyMediumBold.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceMedium),
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                titulo: 'Entregues',
                valor: '$_orcamentosEntregues',
                subtitulo: 'Volume do mês',
                icone: AppIcons.orcamentos,
                corIcone: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppDimensions.spaceMedium),
            Expanded(
              child: _buildKpiCard(
                titulo: 'Com Retorno',
                valor: '$_orcamentosRetorno',
                subtitulo:
                    '${_taxaRetornoPercentual.toStringAsFixed(1)}% do total',
                icone: AppIcons.retorno,
                corIcone: AppColors.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spaceMedium),
        _buildUrgenteCard(),
      ],
    );
  }

  Widget _buildUrgenteCard() {
    final bool temUrgentes = _orcamentosUrgentes > 0;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceMedium),
      decoration: BoxDecoration(
        color: temUrgentes
            ? AppColors.error.withValues(alpha: 0.08)
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: temUrgentes ? AppColors.error : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              AppIcons.urgente,
              color: AppColors.error,
              size: 22,
            ),
          ),
          const SizedBox(width: AppDimensions.spaceMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Orçamentos Urgentes',
                  style: AppTextStyles.bodyMediumBold.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  temUrgentes
                      ? '$_orcamentosUrgentes demanda(s) com prioridade máxima'
                      : 'Nenhuma demanda urgente no período',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: temUrgentes ? AppColors.error : AppColors.borderLight,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            ),
            child: Text(
              '$_orcamentosUrgentes PRIO',
              style: AppTextStyles.caption.copyWith(
                color: temUrgentes ? Colors.white : AppColors.textDisabled,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 3. MÉTRICAS DE CLIENTES
  // ===========================================================================
  Widget _buildSecaoClientes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MÉTRICAS DE CLIENTES',
          style: AppTextStyles.bodyMediumBold.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceMedium),
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                titulo: 'Novos Clientes',
                valor: '$_novosClientes',
                subtitulo: 'Crescimento da base',
                icone: AppIcons.clientes,
                corIcone: AppColors.success,
              ),
            ),
            const SizedBox(width: AppDimensions.spaceMedium),
            Expanded(child: _buildClienteProblematicoCard()),
          ],
        ),
      ],
    );
  }

  Widget _buildClienteProblematicoCard() {
    final bool temProblematicos = _clientesProblematicos > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _abrirListaClientesProblematicos,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.spaceMedium),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(
              color: temProblematicos
                  ? AppColors.warning
                  : AppColors.borderLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Clientes Problemáticos',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    AppIcons.erro,
                    color: temProblematicos
                        ? AppColors.warning
                        : AppColors.textDisabled,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spaceSmall),
              Text(
                '$_clientesProblematicos',
                style: AppTextStyles.titleLarge.copyWith(
                  fontSize: 24,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${_taxaProblematicosVsNovosPercentual.toStringAsFixed(1)}% do total',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textDisabled,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 4. OPERACIONAL E ATENDIMENTOS (TURNOS MANHÃ vs. TARDE)
  // ===========================================================================
  Widget _buildSecaoOperacional() {
    final int total = _servicosManha + _servicosTarde;

    return AppCardContainer(
      titulo: 'TURNOS DE ATENDIMENTO',
      icone: AppIcons.agenda,
      children: [
        const SizedBox(height: AppDimensions.spaceMedium),
        if (total == 0)
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spaceLarge),
            child: Center(
              child: Text(
                'Nenhum serviço registrado neste período.',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textDisabled,
                ),
              ),
            ),
          )
        else
          Row(
            children: [
              // Gráfico de Rosca / Donut
              SizedBox(
                width: 130,
                height: 130,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 32,
                    sections: [
                      PieChartSectionData(
                        color: AppColors.morningShift,
                        value: _servicosManha.toDouble(),
                        title: total > 0
                            ? '${((_servicosManha / total) * 100).toStringAsFixed(0)}%'
                            : '0%',
                        radius: 28,
                        titleStyle: AppTextStyles.caption.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      PieChartSectionData(
                        color: AppColors.afternoonShift,
                        value: _servicosTarde.toDouble(),
                        title: total > 0
                            ? '${((_servicosTarde / total) * 100).toStringAsFixed(0)}%'
                            : '0%',
                        radius: 28,
                        titleStyle: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spaceLarge),
              // Blocos informativos
              Expanded(
                child: Column(
                  children: [
                    _buildTurnoBloco(
                      titulo: 'Período Manhã',
                      quantidade: _servicosManha,
                      cor: AppColors.morningShift,
                      icone: AppIcons.manha,
                    ),
                    const SizedBox(height: AppDimensions.spaceSmall),
                    _buildTurnoBloco(
                      titulo: 'Período Tarde',
                      quantidade: _servicosTarde,
                      cor: AppColors.afternoonShift,
                      icone: AppIcons.tarde,
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildTurnoBloco({
    required String titulo,
    required int quantidade,
    required Color cor,
    required IconData icone,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: cor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icone, color: cor, size: 20),
          const SizedBox(width: AppDimensions.spaceSmall),
          Expanded(
            child: Text(
              titulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '$quantidade serv.',
            style: AppTextStyles.bodyMediumBold.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // COMPONENTES AUXILIARES
  // ===========================================================================
  Widget _buildKpiCard({
    required String titulo,
    required String valor,
    required String subtitulo,
    required IconData icone,
    required Color corIcone,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceMedium),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(icone, color: corIcone, size: 20),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceSmall),
          Text(
            valor,
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 24,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return AppCardContainer(
      titulo: 'VISÃO GERAL COMPARATIVA',
      icone: AppIcons.dashboard,
      children: [
        const SizedBox(height: AppDimensions.spaceLarge),
        SizedBox(
          height: 190,
          child: BarChart(
            BarChartData(
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (group) =>
                      AppColors.cardBackground.withValues(alpha: 0.9),
                ),
              ),
              alignment: BarChartAlignment.spaceAround,
              gridData: const FlGridData(show: false),
              titlesData: _buildChartTitles(
                bottomTitles: _stats6Meses
                    .map((d) => d['month'] as String)
                    .toList(),
              ),
              borderData: FlBorderData(show: false),
              barGroups: _stats6Meses.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: (data['orcamentos'] as num).toDouble(),
                      color: _corOrcamentos,
                      width: 7,
                    ),
                    BarChartRodData(
                      toY: (data['clientes'] as num).toDouble(),
                      color: _corClientes,
                      width: 7,
                    ),
                    BarChartRodData(
                      toY: (data['retornos'] as num).toDouble(),
                      color: _corRetornos,
                      width: 7,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spaceMedium),
        _buildLegend([
          _LegendItem(color: _corOrcamentos, text: 'Orçamentos'),
          _LegendItem(color: _corClientes, text: 'Clientes'),
          _LegendItem(color: _corRetornos, text: 'Retornos'),
        ]),
      ],
    );
  }

  FlTitlesData _buildChartTitles({List<String> bottomTitles = const []}) {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 35,
          getTitlesWidget: (value, meta) {
            if (value == 0 || value % meta.appliedInterval != 0) {
              return const SizedBox.shrink();
            }
            String text = value >= 1000
                ? '${(value / 1000).toStringAsFixed(1)}k'
                : value.toInt().toString();
            return Text(
              text,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textDisabled,
              ),
            );
          },
        ),
      ),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          interval: 1,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index >= 0 && index < bottomTitles.length) {
              return Padding(
                padding: const EdgeInsets.only(top: AppDimensions.spaceSmall),
                child: Text(
                  bottomTitles[index],
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textDisabled,
                  ),
                ),
              );
            }
            return const Text('');
          },
        ),
      ),
    );
  }

  Widget _buildLegend(List<_LegendItem> items) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spaceSmall,
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: item.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceSmall),
                  Text(item.text, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _LegendItem {
  final Color color;
  final String text;
  _LegendItem({required this.color, required this.text});
}
