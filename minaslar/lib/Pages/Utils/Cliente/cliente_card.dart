import '../../../../Core/Design/design_system.dart';
import '../../../../Core/Services/communication.dart';
import '../../../../Core/Utils/formatters.dart';
import '../../../Features/Modelos/cliente_model.dart';

// **[Propósito]** Componente visual (Card) dedicado à exibição do contato telefônico do cliente, oferecendo ações rápidas integradas para realizar ligação, iniciar conversa no WhatsApp e copiar o número para a área de transferência.
// **[Como usar]** ClienteContatoCard(cliente: dadosCliente, themeColor: Colors.blue, onCopyToClipboard: (texto, item) => copiar(texto));
class ClienteContatoCard extends StatelessWidget {
  final Cliente cliente;
  final Color themeColor;
  final void Function(String text, String item) onCopyToClipboard;

  // **[Propósito]** Constrói o card requerendo os dados do cliente, a cor de destaque do ícone e a função de callback acionada ao realizar um clique longo (long press).
  const ClienteContatoCard({
    super.key,
    required this.cliente,
    required this.themeColor,
    required this.onCopyToClipboard,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      child: InkWell(
        onLongPress: () => onCopyToClipboard(cliente.telefone, 'Telefone'),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceLarge,
            vertical: AppDimensions.spaceSmall,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Icon(
                AppIcons.telefone,
                color: themeColor,
                size: AppDimensions.iconSize,
              ),
              const SizedBox(width: AppDimensions.spaceMedium),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("TELEFONE", style: AppTextStyles.overline),
                    const SizedBox(height: AppDimensions.spaceXSmall),
                    Text(
                      AppFormatters.telefone.maskText(cliente.telefone),
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: () => LauncherUtils.fazerLigacao(cliente.telefone),
                icon: const Icon(AppIcons.ligar),
                tooltip: 'Ligar',
              ),

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
