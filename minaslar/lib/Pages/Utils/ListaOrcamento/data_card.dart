import 'package:intl/intl.dart';
import '../../../../Core/Design/design_system.dart';

class DataCard extends StatelessWidget {
  final String label;
  final DateTime? data;
  final IconData icon;
  final Color color;

  const DataCard({
    super.key,
    required this.label,
    required this.data,
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
        children: [
          Icon(icon, color: color, size: AppDimensions.iconSizeMedium),
          const SizedBox(height: AppDimensions.spaceSmall),
          Text(label, style: AppTextStyles.caption),
          Text(
            data != null ? DateFormat('dd/MM/yy').format(data!) : '--/--',
            style: AppTextStyles.bodyMediumBold,
          ),
        ],
      ),
    );
  }
}
