import '../../../../Core/Design/design_system.dart';
import '../../../Features/Modelos/cliente_model.dart';

// **[Propósito]** Componente visual (Card) que exibe o cabeçalho com as informações principais do cliente (nome e avatar), destacando visualmente através de cores de borda e um selo (badge) caso ele esteja marcado como problemático.
// **[Como usar]** ClienteHeaderCard(cliente: dadosCliente);
class ClienteHeaderCard extends StatelessWidget {
  final Cliente cliente;

  // **[Propósito]** Constrói o cabeçalho exigindo a injeção do modelo de dados do cliente para renderização condicional do seu status de restrição.
  const ClienteHeaderCard({super.key, required this.cliente});

  @override
  Widget build(BuildContext context) {
    final isProblematico = cliente.clienteProblematico;
    final statusColor = isProblematico ? AppColors.error : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceLarge),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border(left: BorderSide(color: statusColor, width: 5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: statusColor.withValues(alpha: 0.15),
            child: Icon(AppIcons.clientes, color: statusColor, size: 28),
          ),
          const SizedBox(width: AppDimensions.spaceMedium),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cliente.nome, style: AppTextStyles.titleMedium),

                if (isProblematico) ...[
                  const SizedBox(height: AppDimensions.spaceXSmall),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSmall,
                      ),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      "CLIENTE PROBLEMÁTICO",
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.error,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
