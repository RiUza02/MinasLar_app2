import '../../../../Core/Design/design_system.dart';
import 'kpi_card.dart';

// **[Propósito]** Componente que agrupa e exibe as métricas focadas em clientes no dashboard, comparando o crescimento da base com os clientes que apresentam problemas/atrasos.
// **[Como usar]** Inserido no corpo principal da `DashboardPage`. Requer os valores consolidados de clientes novos, problemáticos, a taxa percentual entre eles e um callback para navegação ou detalhamento.
class ClientesSection extends StatelessWidget {
  final int novosClientes;
  final int clientesProblematicos;
  final double taxaProblematicosVsNovosPercentual;
  final VoidCallback onProblematicosTap;

  const ClientesSection({
    super.key,
    required this.novosClientes,
    required this.clientesProblematicos,
    required this.taxaProblematicosVsNovosPercentual,
    required this.onProblematicosTap,
  });

  @override
  Widget build(BuildContext context) {
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
              child: KpiCard(
                titulo: 'Novos Clientes',
                valor: '$novosClientes',
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

  // **[Subcomponente: Card Interativo de Alerta]** Constrói um card específico para clientes problemáticos.
  // **[Comportamento: Feedback Visual]** Aplica bordas e ícones de alerta (amarelo/warning) dinamicamente caso existam clientes problemáticos, além de responder ao toque do usuário.
  Widget _buildClienteProblematicoCard() {
    final bool temProblematicos = clientesProblematicos > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onProblematicosTap,
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
                '$clientesProblematicos',
                style: AppTextStyles.titleLarge.copyWith(
                  fontSize: 24,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${taxaProblematicosVsNovosPercentual.toStringAsFixed(1)}% do total',
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
}
