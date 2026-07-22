import '../Design/design_system.dart';

// **[Propósito]** Define a semântica visual dos alertas flutuantes (sucesso, erro ou informação neutra).
enum FeedbackType { success, error, info }

// **[Propósito]** Serviço centralizado para exibição de alertas flutuantes (SnackBars) temporários e padronizados com o Design System.
// **[Como usar]** AppFeedback.show(context, 'Dados salvos com sucesso!', type: FeedbackType.success);
class AppFeedback {
  AppFeedback._();

  // **[Propósito]** Mapeia a cor do alerta com base no tipo semântico e renderiza o SnackBar na tela atual.
  // **[Parâmetros]** context (BuildContext) -> Contexto da UI; message (String) -> Texto do aviso; type (FeedbackType) -> Define a cor de fundo (padrão: info).
  static void show(
    BuildContext context,
    String message, {
    FeedbackType type = FeedbackType.info,
  }) {
    Color backgroundColor;
    switch (type) {
      case FeedbackType.success:
        backgroundColor = AppColors.success;
        break;
      case FeedbackType.error:
        backgroundColor = AppColors.error;
        break;
      case FeedbackType.info:
        backgroundColor = AppColors.textDisabled;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }
}
