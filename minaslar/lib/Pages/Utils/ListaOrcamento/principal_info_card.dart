import '../../../../Core/Design/design_system.dart';
import '../../../../Features/Modelos/orcamento_model.dart';

class PrincipalInfoCard extends StatelessWidget {
  final Orcamento orcamento;
  final Color borderColor;
  final Color secondaryColor;

  const PrincipalInfoCard({
    super.key,
    required this.orcamento,
    required this.borderColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spaceXLarge),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border(left: BorderSide(color: borderColor, width: 6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            orcamento.titulo,
            style: AppTextStyles.titleLarge.copyWith(
              decoration: orcamento.entregue
                  ? TextDecoration.lineThrough
                  : null,
              decorationColor: AppColors.textDisabled,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceLarge),
          const Divider(color: AppColors.borderLight),
          const SizedBox(height: AppDimensions.spaceLarge),
          Row(
            children: [
              Icon(
                orcamento.ehRetorno ? AppIcons.retorno : AppIcons.descricao,
                color: orcamento.ehRetorno
                    ? AppColors.adminColor
                    : secondaryColor,
                size: AppDimensions.iconSizeSmall,
              ),
              const SizedBox(width: AppDimensions.spaceSmall),
              Text(
                orcamento.ehRetorno ? "GARANTIA/RETORNO" : "DESCRIÇÃO",
                style: AppTextStyles.cardHeader.copyWith(
                  color: orcamento.ehRetorno
                      ? AppColors.adminColor
                      : secondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceSmall),
          Text(
            (orcamento.descricao?.isNotEmpty ?? false)
                ? orcamento.descricao!
                : "Sem descrição detalhada.",
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
