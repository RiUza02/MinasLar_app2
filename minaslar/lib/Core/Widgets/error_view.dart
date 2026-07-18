import '../Design/design_system.dart';

/// Widget para exibir uma tela amigável de erro genérico com mensagem e um botão de ação.
/// **[Onde usar]**: Em blocos de captura de exceções (`try-catch`), estados de erro de reações/cubits,
/// ou telas que falharam ao carregar dados essenciais da API/Banco de dados.
class AppErrorView extends StatelessWidget {
  final String message;
  final String buttonText;
  final VoidCallback onTryAgain;
  final IconData icon;

  const AppErrorView({
    super.key,
    required this.message,
    required this.buttonText,
    required this.onTryAgain,
    this.icon = AppIcons.erro,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone indicativo usando a cor semântica de erro do sistema
            Icon(
              icon,
              size: AppDimensions.iconSizeLarge,
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimensions.spaceMedium),
            // Exibição da mensagem descritiva do erro tratada para o usuário
            Text(
              message,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spaceLarge),
            // Botão de ação para disparar a tentativa de recarregamento
            ElevatedButton(onPressed: onTryAgain, child: Text(buttonText)),
          ],
        ),
      ),
    );
  }
}
