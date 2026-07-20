import '../../../../Core/Design/design_system.dart';
import '../../../Features/Modelos/cliente_model.dart';

/// [uso] Exibe o cabeçalho do cliente com nome e indicador visual
/// caso ele esteja marcado como problemático.
class ClienteHeaderCard extends StatelessWidget {
  /// Dados do cliente.
  final Cliente cliente;

  const ClienteHeaderCard({super.key, required this.cliente});

  @override
  Widget build(BuildContext context) {
    // Verifica se o cliente possui restrição.
    final isProblematico = cliente.clienteProblematico;

    // Define a cor do cabeçalho conforme o status.
    final statusColor = isProblematico ? AppColors.error : AppColors.primary;

    return Container(
      // Espaçamento interno do card.
      padding: const EdgeInsets.all(AppDimensions.spaceLarge),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        // Barra lateral indicando o status.
        border: Border(left: BorderSide(color: statusColor, width: 5)),
      ),
      child: Row(
        children: [
          // Avatar com ícone do cliente.
          CircleAvatar(
            radius: 24,
            backgroundColor: statusColor.withValues(alpha: 0.15),
            child: Icon(AppIcons.clientes, color: statusColor, size: 28),
          ),
          const SizedBox(width: AppDimensions.spaceMedium),

          // Informações do cliente.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nome do cliente.
                Text(cliente.nome, style: AppTextStyles.titleMedium),

                // Exibe selo caso o cliente seja problemático.
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
