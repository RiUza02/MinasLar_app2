import '../../../../Core/Design/design_system.dart';

class ClienteButton extends StatelessWidget {
  final String nomeCliente;
  final Color themeColor;
  final VoidCallback onTap;

  const ClienteButton({
    super.key,
    required this.nomeCliente,
    required this.themeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spaceLarge),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Icon(AppIcons.cliente, color: themeColor),
            const SizedBox(width: AppDimensions.spaceMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("CLIENTE", style: AppTextStyles.caption),
                  Text(
                    nomeCliente,
                    style: AppTextStyles.bodyMediumBold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(AppIcons.navegar, color: AppColors.textDisabled),
          ],
        ),
      ),
    );
  }
}
