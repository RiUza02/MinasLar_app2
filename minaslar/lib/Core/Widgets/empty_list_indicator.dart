import '../Design/design_system.dart';

/// Widget para exibir um indicador visual amigável quando uma lista está vazia.
///
/// **[Onde usar]**: Centralizado em telas de listagens (como históricos, buscas ou cadastros)
/// sempre que o retorno do banco de dados for uma lista vazia.
class AppEmptyListIndicator extends StatelessWidget {
  final String message;
  final IconData? icon;

  const AppEmptyListIndicator({super.key, required this.message, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceXLarge),
      margin: const EdgeInsets.only(top: AppDimensions.spaceSmall),
      // Container estilizado sutilmente para se integrar ao fundo da tela
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Exibe o ícone opcional com cor discreta se for fornecido
            if (icon != null) ...[
              Icon(icon, size: 40, color: AppColors.textDisabled),
              const SizedBox(height: AppDimensions.spaceMedium),
            ],
            // Mensagem informativa centralizada para o usuário
            Text(
              message,
              style: AppTextStyles.bodyMediumSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
