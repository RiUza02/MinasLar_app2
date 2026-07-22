import 'package:fl_chart/fl_chart.dart';
import '../../../../Core/Design/design_system.dart';
import '../../../../Core/Widgets/widgets.dart';
import 'chart_legend.dart';

// **[Propósito]** Componente visual que exibe um gráfico de barras comparativo das métricas principais ao longo do histórico recente (6 meses).
// **[Como usar]** Utilizado como seção analítica na `DashboardPage`. Requer a lista de estatísticas mensais (`stats6Meses`) e as cores de destaque para as barras de orçamentos, clientes e retornos.
class ComparativoSection extends StatelessWidget {
  final List<Map<String, dynamic>> stats6Meses;
  final Color corOrcamentos;
  final Color corClientes;
  final Color corRetornos;

  const ComparativoSection({
    super.key,
    required this.stats6Meses,
    required this.corOrcamentos,
    required this.corClientes,
    required this.corRetornos,
  });

  @override
  Widget build(BuildContext context) {
    return AppCardContainer(
      titulo: 'VISÃO GERAL COMPARATIVA',
      icone: AppIcons.dashboard,
      children: [
        const SizedBox(height: AppDimensions.spaceLarge),

        // **[Subcomponente: Gráfico de Barras]** Renderiza os grupos de barras representando as métricas mensais lado a lado usando a biblioteca fl_chart.
        SizedBox(
          height: 190,
          child: BarChart(
            BarChartData(
              // **[Comportamento: Interatividade]** Exibe tooltips (balões flutuantes) semi-transparentes ao tocar nas barras.
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (group) =>
                      AppColors.cardBackground.withValues(alpha: 0.9),
                ),
              ),
              alignment: BarChartAlignment.spaceAround,
              gridData: const FlGridData(show: false),
              titlesData: _buildChartTitles(
                bottomTitles: stats6Meses
                    .map((d) => d['month'] as String)
                    .toList(),
              ),
              borderData: FlBorderData(show: false),
              barGroups: stats6Meses.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: (data['orcamentos'] as num).toDouble(),
                      color: corOrcamentos,
                      width: 7,
                    ),
                    BarChartRodData(
                      toY: (data['clientes'] as num).toDouble(),
                      color: corClientes,
                      width: 7,
                    ),
                    BarChartRodData(
                      toY: (data['retornos'] as num).toDouble(),
                      color: corRetornos,
                      width: 7,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spaceMedium),

        // **[Subcomponente: Legenda do Gráfico]** Associa as cores exibidas nas barras aos seus respectivos significados.
        ChartLegend(
          items: [
            LegendItem(color: corOrcamentos, text: 'Orçamentos'),
            LegendItem(color: corClientes, text: 'Clientes'),
            LegendItem(color: corRetornos, text: 'Retornos'),
          ],
        ),
      ],
    );
  }

  // **[Comportamento: Configuração de Eixos]** Formata dinamicamente os eixos X (meses) e Y (quantidades), simplificando valores grandes (ex: 1500 vira '1.5k') para manter o layout limpo.
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
