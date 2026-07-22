import '../../../../Core/Design/design_system.dart';
import 'kpi_card.dart';

// **[Propósito]** Componente visual que apresenta o panorama das métricas de orçamentos do último mês, destacando o volume de entregas, a taxa de retornos e alertando sobre demandas com prioridade máxima.
// **[Como usar]** Utilizado no painel de controle (dashboard) para acompanhamento da fila de trabalho. Requer os dados numéricos consolidados de orçamentos entregues, retornos, a respectiva taxa percentual e a contagem de orçamentos urgentes.
class OrcamentosSection extends StatelessWidget {
  final int orcamentosEntregues;
  final int orcamentosRetorno;
  final double taxaRetornoPercentual;
  final int orcamentosUrgentes;

  const OrcamentosSection({
    super.key,
    required this.orcamentosEntregues,
    required this.orcamentosRetorno,
    required this.taxaRetornoPercentual,
    required this.orcamentosUrgentes,
  });

  @override
  Widget build(BuildContext context) {
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

        // **[Subcomponente: Indicadores Principais (KPIs)]** Distribui horizontalmente os cards de resumo para orçamentos "Entregues" e "Com Retorno", garantindo o mesmo peso visual através do componente reutilizável KpiCard.
        Row(
          children: [
            Expanded(
              child: KpiCard(
                titulo: 'Entregues',
                valor: '$orcamentosEntregues',
                subtitulo: 'Volume do mês',
                icone: AppIcons.orcamentos,
                corIcone: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppDimensions.spaceMedium),
            Expanded(
              child: KpiCard(
                titulo: 'Com Retorno',
                valor: '$orcamentosRetorno',
                subtitulo:
                    '${taxaRetornoPercentual.toStringAsFixed(1)}% do total',
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

  // **[Subcomponente: Card de Alerta de Urgência]** Constrói um bloco dedicado exclusivamente para evidenciar demandas prioritárias (urgentes).
  // **[Comportamento: Feedback Visual Dinâmico]** O estilo do card muda reativamente baseado no valor de 'orcamentosUrgentes'. Se houver urgências (> 0), aplica tons de erro/alerta (vermelho) para atrair a atenção do usuário. Caso contrário, adota uma aparência neutra e discreta.
  Widget _buildUrgenteCard() {
    final bool temUrgentes = orcamentosUrgentes > 0;

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
                      ? '$orcamentosUrgentes demanda(s) com prioridade máxima'
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
              '$orcamentosUrgentes PRIO',
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
}
