import '../../Core/Design/design_system.dart';

/// Indicador visual de feedback imediato para critérios de validação em tempo real.
///
/// **[Onde usar]**: Geralmente posicionado logo abaixo de campos de entrada complexos.
/// Exemplos: Abaixo de campos de senha (requisitos de segurança) ou telefone (mínimo de dígitos).
class AppValidationIndicator extends StatelessWidget {
  /// Define o estado visual do componente (`true` para válido, `false` para pendente).
  final bool isValid;

  /// Texto descritivo da regra exigida (ex: "Mínimo de 6 caracteres").
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
        // Ícone alternado dinamicamente usando as cores semânticas de sucesso ou erro
        Icon(
          isValid ? AppIcons.valido : AppIcons.invalido,
          color: isValid ? AppColors.success : AppColors.error,
          size: AppDimensions.iconSizeXSmall,
        ),
        const SizedBox(width: AppDimensions.spaceXSmall),
        // Texto descritivo com a cor reativa ao estado da validação
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
