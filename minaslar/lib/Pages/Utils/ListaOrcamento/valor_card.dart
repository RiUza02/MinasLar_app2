import '../../../../Core/Design/design_system.dart';

class ValorCard extends StatelessWidget {
  final String textoValor;
  final Color corValor;

  const ValorCard({
    super.key,
    required this.textoValor,
    required this.corValor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.spaceLarge,
        horizontal: AppDimensions.spaceXLarge,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("VALOR TOTAL", style: AppTextStyles.cardHeader),
          Text(
            textoValor,
            style: AppTextStyles.titleLarge.copyWith(color: corValor),
          ),
        ],
      ),
    );
  }
}
