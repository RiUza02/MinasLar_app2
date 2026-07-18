import '../Design/design_system.dart';

/// Definição dos tipos de feedback visual disponíveis no sistema.
///
/// [Uso] Indica a semântica do alerta que será exibido para o usuário,
/// alterando a cor de fundo do componente para corresponder ao estado (sucesso, erro ou informativo).
enum FeedbackType { success, error, info }

/// Serviço centralizado para exibição de alertas flutuantes (SnackBars) padronizados.
///
/// [Uso] Utilizado em qualquer ponto da camada de apresentação para exibir avisos rápidos
/// e temporários ao usuário (como confirmações de salvamento, mensagens de erro de API ou alertas informativos),
/// garantindo consistência com as cores do Design System.
class AppFeedback {
  AppFeedback._();

  /// Renderiza e exibe um [SnackBar] customizado na tela.
  ///
  /// [Uso] Chame este método estático passando o [context] atual da árvore de widgets,
  /// a [message] que deseja exibir e o [type] para definir a estilização visual do alerta.
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
