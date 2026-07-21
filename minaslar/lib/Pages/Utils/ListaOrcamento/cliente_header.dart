import '../../../Core/Design/design_system.dart';
import '../../../Features/Modelos/cliente_model.dart';

class ClienteHeader extends StatelessWidget {
  final Cliente cliente;

  const ClienteHeader({super.key, required this.cliente});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceLarge),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: const Border(
          left: BorderSide(color: AppColors.adminColor, width: 4),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.adminColor.withAlpha(38),
            child: const Icon(
              AppIcons.cliente,
              color: AppColors.adminColor,
              size: AppDimensions.iconSizeMedium,
            ),
          ),
          const SizedBox(width: AppDimensions.spaceLarge),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("CLIENTE SELECIONADO", style: AppTextStyles.caption),
                const SizedBox(height: AppDimensions.spaceXSmall),
                Text(
                  cliente.nome,
                  style: AppTextStyles.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
