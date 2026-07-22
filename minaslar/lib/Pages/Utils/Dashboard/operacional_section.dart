import 'package:fl_chart/fl_chart.dart';
import '../../../../Core/Design/design_system.dart';
import '../../../../Core/Widgets/widgets.dart';

// **[Propósito]** Componente visual que exibe a distribuição do volume de atendimentos operacionais segmentado por turnos (manhã e tarde).
// **[Como usar]** Utilizado no painel de métricas da `DashboardPage`. Requer a passagem das quantidades absolutas de serviços realizados em cada turno.
class OperacionalSection extends StatelessWidget {
  final int servicosManha;
  final int servicosTarde;

  const OperacionalSection({
    super.key,
    required this.servicosManha,
    required this.servicosTarde,
  });

  @override
  Widget build(BuildContext context) {
    final int total = servicosManha + servicosTarde;

    return AppCardContainer(
      titulo: 'TURNOS DE ATENDIMENTO',
      icone: AppIcons.agenda,
      children: [
        const SizedBox(height: AppDimensions.spaceMedium),

        // **[Comportamento: Estado Vazio (Empty State)]** Renderiza uma mensagem descritiva caso a soma dos serviços seja zero, evitando a exibição de um gráfico vazio ou possíveis erros de divisão por zero na porcentagem.
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
              // **[Subcomponente: Gráfico de Rosca]** Renderiza visualmente a proporção percentual de serviços entre os turnos em um formato de Donut Chart usando a biblioteca fl_chart.
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
                        value: servicosManha.toDouble(),
                        title: total > 0
                            ? '${((servicosManha / total) * 100).toStringAsFixed(0)}%'
                            : '0%',
                        radius: 28,
                        titleStyle: AppTextStyles.caption.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      PieChartSectionData(
                        color: AppColors.afternoonShift,
                        value: servicosTarde.toDouble(),
                        title: total > 0
                            ? '${((servicosTarde / total) * 100).toStringAsFixed(0)}%'
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

              // **[Subcomponente: Lista de Detalhes]** Agrupa os blocos informativos que mostram os valores absolutos empilhados verticalmente ao lado do gráfico percentual.
              Expanded(
                child: Column(
                  children: [
                    _buildTurnoBloco(
                      titulo: 'Período Manhã',
                      quantidade: servicosManha,
                      cor: AppColors.morningShift,
                      icone: AppIcons.manha,
                    ),
                    const SizedBox(height: AppDimensions.spaceSmall),
                    _buildTurnoBloco(
                      titulo: 'Período Tarde',
                      quantidade: servicosTarde,
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

  // **[Subcomponente: Bloco Informativo de Turno]** Cria um card horizontal condensado para exibir a quantidade absoluta de serviços de um turno específico, utilizando a cor tema do respectivo período de forma leve no fundo e bordas.
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
}
