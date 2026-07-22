import '../Design/design_system.dart';

// **[Propósito]** Exibe uma tela de erro amigável com ícone semântico, mensagem explicativa e um botão para tentativa de recuperação.
// **[Como usar]** AppErrorView(message: 'Falha ao carregar dados.', buttonText: 'Tentar Novamente', onTryAgain: () => buscarDados());
class AppErrorView extends StatelessWidget {
  // **[Parâmetros]** message (String) -> Texto descritivo da falha; buttonText (String) -> Rótulo do botão de ação.
  final String message;
  final String buttonText;

  // **[Parâmetros]** onTryAgain (VoidCallback) -> Função disparada no clique de recuperação; icon (IconData) -> Ícone de alerta (padrão: AppIcons.erro).
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
            // Ícone indicativo em destaque utilizando a cor semântica de erro do sistema.
            Icon(
              icon,
              size: AppDimensions.iconSizeLarge,
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimensions.spaceMedium),
            // Mensagem descritiva centralizada para orientar o usuário sobre o problema.
            Text(
              message,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spaceLarge),
            // Botão interativo que permite reexecutar a chamada ou fluxo que falhou.
            ElevatedButton(onPressed: onTryAgain, child: Text(buttonText)),
          ],
        ),
      ),
    );
  }
}
