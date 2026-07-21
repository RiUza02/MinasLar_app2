import '../../../Core/Design/design_system.dart';
import '../../../Core/Widgets/widgets.dart';
import '../../Utils/ListaOrcamento/orcamento_form_controller.dart'; // <-- Importação atualizada

class StatusCard extends StatelessWidget {
  final OrcamentoFormController controller; // <-- Tipado para a classe base

  const StatusCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AppCardContainer(
      icone: AppIcons.info,
      titulo: 'STATUS DO SERVIÇO',
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            controller.foiEntregue ? "CONCLUÍDO" : "PENDENTE",
            style: AppTextStyles.bodyMediumBold.copyWith(
              color: controller.foiEntregue
                  ? AppColors.success
                  : AppColors.morningShift,
            ),
          ),
          subtitle: Text(
            "Indica se o serviço já foi finalizado.",
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          value: controller.foiEntregue,
          onChanged: (value) => controller.setStatus(entregue: value),
          activeThumbColor: AppColors.success,
          secondary: Icon(
            controller.foiEntregue ? AppIcons.valido : AppIcons.pendente,
            color: controller.foiEntregue
                ? AppColors.success
                : AppColors.morningShift,
          ),
        ),
        const Divider(
          height: AppDimensions.spaceLarge,
          color: AppColors.borderLight,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            "Marcar como Urgente",
            style: AppTextStyles.bodyMediumBold.copyWith(
              color: controller.ehUrgente ? AppColors.error : null,
            ),
          ),
          subtitle: Text(
            "Prioriza o serviço na listagem e na agenda.",
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          value: controller.ehUrgente,
          onChanged: (value) => controller.setStatus(urgente: value),
          activeThumbColor: AppColors.error,
          secondary: Icon(
            AppIcons.urgente,
            color: controller.ehUrgente
                ? AppColors.error
                : AppColors.textDisabled,
          ),
        ),
        const Divider(
          height: AppDimensions.spaceLarge,
          color: AppColors.borderLight,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            "Marcar como Retorno",
            style: AppTextStyles.bodyMediumBold,
          ),
          subtitle: Text(
            "Use para serviços de garantia ou revisão.",
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          value: controller.ehRetorno,
          onChanged: (value) => controller.setStatus(retorno: value),
          activeThumbColor: AppColors.adminColor,
          secondary: const Icon(AppIcons.retorno, color: AppColors.adminColor),
        ),
      ],
    );
  }
}
