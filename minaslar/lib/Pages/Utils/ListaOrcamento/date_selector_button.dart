import '../../../Core/Design/design_system.dart';

class DateSelectorButton extends StatelessWidget {
  final IconData icon;
  final String texto;
  final VoidCallback onTap;

  const DateSelectorButton({
    super.key,
    required this.icon,
    required this.texto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spaceLarge),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.textDisabled,
              size: AppDimensions.iconSizeMedium,
            ),
            const SizedBox(width: AppDimensions.spaceMedium),
            Text(texto, style: AppTextStyles.bodyLarge),
            const Spacer(),
            const Icon(AppIcons.dropdown, color: AppColors.textDisabled),
          ],
        ),
      ),
    );
  }
}
