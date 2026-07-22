import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../Core/Design/design_system.dart';
import '../../../../Core/Widgets/widgets.dart';

// **[Propósito]** Componente visual responsável por exibir o resumo financeiro (faturamento), apresentando os valores consolidados (acumulado e atual) acompanhados de um gráfico de linhas histórico.
// **[Como usar]** Utilizado como seção principal e de maior destaque na `DashboardPage`. Requer os valores totais do semestre, do mês atual e a série histórica de dados (`faturamento6MesesData`).
class FaturamentoSection extends StatelessWidget {
  final double faturamentoTotal6Meses;
  final double faturamentoMesAtual;
  final List<Map<String, dynamic>> faturamento6MesesData;

  const FaturamentoSection({
    super.key,
    required this.faturamentoTotal6Meses,
    required this.faturamentoMesAtual,
    required this.faturamento6MesesData,
  });

  @override
  Widget build(BuildContext context) {
    // **[Comportamento: Formatação Monetária]** Formata os valores numéricos brutos para o padrão de moeda local (Real Brasileiro - R$).
    final totalFormatado = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    ).format(faturamentoTotal6Meses);

    final mesAtualFormatado = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    ).format(faturamentoMesAtual);

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

        // **[Subcomponente: Gráfico de Linhas]** Renderiza a evolução do faturamento ao longo dos últimos 6 meses usando fl_chart. Inclui uma área sombreada com gradiente para melhor estética.
        SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              // **[Comportamento: Interatividade]** Exibe tooltips monetárias semi-transparentes ao tocar nos pontos do gráfico.
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
                bottomTitles: faturamento6MesesData
                    .map((d) => d['month'] as String)
                    .toList(),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: faturamento6MesesData.asMap().entries.map((entry) {
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

  // **[Comportamento: Configuração de Eixos]** Formata dinamicamente os eixos X (meses) e Y (valores), abreviando milhares (ex: 5000 para '5.0k') para otimizar o espaço visual do gráfico.
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
}
