import 'package:intl/intl.dart';
import '../../../../Core/Design/design_system.dart';

/// [uso] Exibe um orçamento no histórico do cliente,
/// destacando o orçamento mais recente ou um orçamento específico.
class OrcamentoHistoryCard extends StatelessWidget {
  /// Dados do orçamento.
  final Map<String, dynamic> orcamento;

  /// Indica se é o orçamento mais recente.
  final bool isLast;

  /// Indica se este orçamento deve receber destaque.
  final bool isHighlight;

  /// Define se as opções administrativas devem ser exibidas.
  final bool isAdmin;

  const OrcamentoHistoryCard({
    super.key,
    required this.orcamento,
    required this.isLast,
    required this.isHighlight,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    // Obtém os dados do orçamento.
    final titulo = orcamento['titulo'] ?? 'Serviço';
    final valor = orcamento['valor'];
    final dataPega = DateTime.tryParse(orcamento['data_pega'] ?? '');

    // Define a cor conforme o destaque do orçamento.
    final Color statusColor = isHighlight
        ? AppColors.adminColor
        : isLast
        ? AppColors.success
        : AppColors.textDisabled;

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceSmall),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),

        // Destaca os cartões especiais.
        side: isLast || isHighlight
            ? BorderSide(color: statusColor.withValues(alpha: 0.7), width: 1.5)
            : const BorderSide(color: AppColors.borderLight),
      ),
      child: ListTile(
        // Espaçamento interno.
        contentPadding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spaceSmall,
          horizontal: AppDimensions.spaceLarge,
        ),

        // Ícone do orçamento.
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isHighlight ? Icons.star : Icons.build_circle_outlined,
              color: statusColor,
            ),
          ],
        ),

        // Título do orçamento.
        title: Text(titulo, style: AppTextStyles.bodyMedium),

        // Data e valor.
        subtitle: Row(
          children: [
            // Data do orçamento.
            if (dataPega != null)
              Text(
                DateFormat('dd/MM/yyyy').format(dataPega),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textDisabled,
                ),
              ),

            const Spacer(),

            // Valor do orçamento.
            if (valor != null)
              Text(
                NumberFormat.currency(
                  locale: 'pt_BR',
                  symbol: 'R\$',
                ).format(valor),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.adminColor,
                ),
              ),
          ],
        ),

        // Menu de ações para administradores.
        trailing: isAdmin
            ? PopupMenuButton<String>(
                onSelected: (choice) {
                  // TODO: Implementar edição e exclusão.
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'editar', child: Text('Editar')),
                  const PopupMenuItem(value: 'excluir', child: Text('Excluir')),
                ],
              )
            : null,
      ),
    );
  }
}
