import '../../../../Core/Design/design_system.dart';
import '../../../../Core/Services/communication.dart';
import '../../../../Core/Utils/formatters.dart';
import '../../../Features/Modelos/cliente_model.dart';

/// [uso] Card para exibir o telefone do cliente com ações rápidas
/// de ligação, WhatsApp e cópia do número.
class ClienteContatoCard extends StatelessWidget {
  /// Dados do cliente.
  final Cliente cliente;

  /// Cor utilizada no ícone principal.
  final Color themeColor;

  /// Callback executado ao copiar o telefone.
  final void Function(String text, String item) onCopyToClipboard;

  const ClienteContatoCard({
    super.key,
    required this.cliente,
    required this.themeColor,
    required this.onCopyToClipboard,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      // Necessário para o efeito do InkWell.
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      child: InkWell(
        // Copia o telefone ao manter pressionado.
        onLongPress: () => onCopyToClipboard(cliente.telefone, 'Telefone'),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: Container(
          // Espaçamento interno do card.
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceLarge,
            vertical: AppDimensions.spaceSmall,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            // Borda padrão.
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              // Ícone do telefone.
              Icon(
                AppIcons.telefone,
                color: themeColor,
                size: AppDimensions.iconSize,
              ),
              const SizedBox(width: AppDimensions.spaceMedium),

              // Informações do telefone.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("TELEFONE", style: AppTextStyles.overline),
                    const SizedBox(height: AppDimensions.spaceXSmall),

                    // Exibe o telefone formatado.
                    Text(
                      AppFormatters.telefone.maskText(cliente.telefone),
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              // Inicia uma ligação.
              IconButton(
                onPressed: () => LauncherUtils.fazerLigacao(cliente.telefone),
                icon: const Icon(AppIcons.ligar),
                tooltip: 'Ligar',
              ),

              // Abre uma conversa no WhatsApp.
              IconButton(
                onPressed: () => LauncherUtils.abrirWhatsApp(cliente.telefone),
                icon: const Icon(AppIcons.chat, color: AppColors.success),
                tooltip: 'WhatsApp',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
