import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

/// Indicador visual de feedback imediato para critérios de validação em tempo real.
///
/// [Onde usar]: Geralmente posicionado logo abaixo de campos de entrada complexos
/// como Senhas (para mostrar requisitos de segurança), Telefone (para indicar
/// quantidade mínima de dígitos) ou CPF (para acusar validade algorítmica).
class AppValidationIndicator extends StatelessWidget {
  /// Define o estado visual do componente (`true` para verde/valido, `false` para vermelho/pendente).
  final bool isValid;

  /// Texto descritivo da regra exigida (ex: "Mínimo de 6 caracteres", "Contém caractere especial").
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
        Icon(
          isValid ? AppIcons.valido : AppIcons.invalido,
          color: isValid ? AppColors.success : AppColors.error,
          size: AppDimensions.iconSizeXSmall,
        ),
        const SizedBox(width: AppDimensions.spaceXSmall),
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
