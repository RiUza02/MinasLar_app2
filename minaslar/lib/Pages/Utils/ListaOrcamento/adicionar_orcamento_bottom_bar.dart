import '../../../Core/Design/design_system.dart';

class AdicionarOrcamentoBottomBar extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const AdicionarOrcamentoBottomBar({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceLarge),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryAlternative,
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: AppColors.textPrimary,
                  strokeWidth: 2.5,
                ),
              )
            : Text("ADICIONAR ORÇAMENTO", style: AppTextStyles.button),
      ),
    );
  }
}
