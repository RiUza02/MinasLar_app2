import '../../../../Core/Design/design_system.dart';

class InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const InfoTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceLarge),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: AppDimensions.iconSize),
          const SizedBox(height: AppDimensions.spaceSmall),
          Text(label, style: AppTextStyles.caption),
          Text(value, style: AppTextStyles.bodyMediumBold),
        ],
      ),
    );
  }
}
