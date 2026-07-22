import '../../Core/Design/design_system.dart';

// **[Propósito]** Indicador visual para dar feedback imediato ao usuário sobre o atendimento a critérios de validação em formulários.
// **[Como usar]** AppValidationIndicator(isValid: _senha.length >= 6, text: 'Mínimo de 6 caracteres');
class AppValidationIndicator extends StatelessWidget {
  // **[Parâmetros]** isValid (bool) -> Define a cor e o ícone (sucesso ou erro); text (String) -> Descrição da regra exigida.
  final bool isValid;
  final String text;

  const AppValidationIndicator({
    super.key,
    required this.isValid,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Alterna o ícone e a tonalidade semântica (vermelho/verde) dinamicamente conforme o estado do requisito.
        Icon(
          isValid ? AppIcons.valido : AppIcons.invalido,
          color: isValid ? AppColors.success : AppColors.error,
          size: AppDimensions.iconSizeXSmall,
        ),
        const SizedBox(width: AppDimensions.spaceXSmall),
        // Rótulo descritivo com a cor sincronizada ao estado atual da validação.
        Text(
          text,
          style: AppTextStyles.caption.copyWith(
            color: isValid ? AppColors.success : AppColors.error,
          ),
        ),
      ],
    );
  }
}
