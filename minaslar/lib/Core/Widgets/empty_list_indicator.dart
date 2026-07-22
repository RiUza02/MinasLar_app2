import '../Design/design_system.dart';

// **[Propósito]** Exibe um indicador visual amigável para listas vazias, mantendo a consistência visual quando não há dados a serem renderizados.
// **[Como usar]** AppEmptyListIndicator(message: 'Nenhum orçamento encontrado.', icon: Icons.inbox);
class AppEmptyListIndicator extends StatelessWidget {
  // **[Parâmetros]** message (String) -> Texto explicativo sobre o estado vazio; icon (IconData?) -> Ícone ilustrativo opcional.
  final String message;
  final IconData? icon;

  const AppEmptyListIndicator({super.key, required this.message, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceXLarge),
      margin: const EdgeInsets.only(top: AppDimensions.spaceSmall),
      // Estilização sutil com transparência para integrar o card organicamente ao fundo da listagem.
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Renderiza o bloco do ícone apenas quando um IconData é informado.
            if (icon != null) ...[
              Icon(icon, size: 40, color: AppColors.textDisabled),
              const SizedBox(height: AppDimensions.spaceMedium),
            ],
            // Mensagem informativa centralizada orientando o usuário sobre a ausência de registros.
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
