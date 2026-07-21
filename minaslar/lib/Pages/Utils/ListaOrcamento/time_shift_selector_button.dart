import '../../../Core/Design/design_system.dart';

class TimeShiftSelectorButton extends StatelessWidget {
  final String texto;
  final IconData icon;
  final Color cor;
  final bool isSelected;
  final VoidCallback onTap;

  const TimeShiftSelectorButton({
    super.key,
    required this.texto,
    required this.icon,
    required this.cor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.spaceMedium,
          ),
          decoration: BoxDecoration(
            color: isSelected ? cor.withAlpha(51) : AppColors.inputBackground,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(
              color: isSelected ? cor : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? cor : AppColors.textDisabled,
                size: AppDimensions.iconSize,
              ),
              const SizedBox(height: AppDimensions.spaceSmall),
              Text(
                texto,
                style:
                    (isSelected
                            ? AppTextStyles.bodyMediumBold
                            : AppTextStyles.bodyMedium)
                        .copyWith(
                          color: isSelected ? cor : AppColors.textDisabled,
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
