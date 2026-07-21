import '../../../../Core/Design/design_system.dart';
import '../../../../Features/Modelos/orcamento_model.dart';

class StatusActionCard extends StatelessWidget {
  final Orcamento orcamento;
  final VoidCallback onStatusChange;

  const StatusActionCard({
    super.key,
    required this.orcamento,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final bool isConcluido = orcamento.entregue;
    final bool ehRetorno = orcamento.ehRetorno;
    final bool ehUrgente = orcamento.ehUrgente;
    final bool isAtrasado = orcamento.isAtrasado;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (isConcluido) {
      statusColor = AppColors.primary;
      statusIcon = AppIcons.valido;
      statusText = "CONCLUÍDO";
    } else if (isAtrasado) {
      statusColor = AppColors.warning;
      statusIcon = AppIcons.pendente;
      statusText = "ATRASADO";
    } else if (ehRetorno) {
      statusColor = AppColors.adminColor;
      statusIcon = AppIcons.retorno;
      statusText = "EM GARANTIA";
    } else {
      statusColor = AppColors.morningShift;
      statusIcon = AppIcons.pendente;
      statusText = "PENDENTE";
    }

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.spaceMedium,
              horizontal: AppDimensions.spaceLarge,
            ),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(38),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              border: Border.all(color: statusColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  statusIcon,
                  color: statusColor,
                  size: AppDimensions.iconSizeMedium,
                ),
                const SizedBox(width: AppDimensions.spaceMedium),
                Text(
                  statusText,
                  style: AppTextStyles.bodyLargeBold.copyWith(
                    color: statusColor,
                  ),
                ),
                if (ehUrgente && !isConcluido) ...[
                  const SizedBox(width: AppDimensions.spaceSmall),
                  const Text(
                    "|",
                    style: TextStyle(color: AppColors.textDisabled),
                  ),
                  const SizedBox(width: AppDimensions.spaceSmall),
                  const Icon(
                    AppIcons.urgente,
                    color: AppColors.error,
                    size: AppDimensions.iconSizeSmall,
                  ),
                  const SizedBox(width: AppDimensions.spaceXSmall),
                  Text(
                    "URGENTE",
                    style: AppTextStyles.bodyMediumBold.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.spaceMedium),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: IconButton(
            icon: const Icon(
              AppIcons.atualizar,
              color: AppColors.textSecondary,
            ),
            tooltip: "Alterar Status",
            onPressed: onStatusChange,
          ),
        ),
      ],
    );
  }
}
