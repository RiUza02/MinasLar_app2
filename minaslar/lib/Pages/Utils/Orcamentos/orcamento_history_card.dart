import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../Core/Design/design_system.dart';
import '../../../../Core/Widgets/widgets.dart';
import '../../Orcamento/edita_orcamento.dart';

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

  /// Callback para notificar o widget pai que a lista precisa ser atualizada.
  final VoidCallback? onActionCompleted;

  /// Callback para quando o card é pressionado.
  final VoidCallback? onTap;

  const OrcamentoHistoryCard({
    super.key,
    required this.orcamento,
    required this.isLast,
    required this.isHighlight,
    required this.isAdmin,
    this.onActionCompleted,
    this.onTap,
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
        onTap: onTap,
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
                  // Utiliza uma função anônima assíncrona para lidar com as operações.
                  () async {
                    if (choice == 'editar') {
                      // Navega para a tela de edição.
                      final bool? foiAtualizado = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditarOrcamento(orcamento: orcamento),
                        ),
                      );
                      if (foiAtualizado == true) {
                        onActionCompleted?.call();
                      }
                    } else if (choice == 'excluir') {
                      // Exibe um diálogo de confirmação antes de excluir.
                      final confirmar = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppColors.cardBackground,
                          title: Text(
                            "Excluir Orçamento",
                            style: AppTextStyles.titleMedium,
                          ),
                          content: Text(
                            "Tem certeza? Esta ação não pode ser desfeita.",
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("CANCELAR"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                "EXCLUIR",
                                style: TextStyle(color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirmar == true && context.mounted) {
                        try {
                          await Supabase.instance.client
                              .from('orcamentos')
                              .delete()
                              .eq('id', orcamento['id']);

                          // 1. Verificação obrigatória após o "async gap" (await)
                          if (!context.mounted) return;

                          AppFeedback.show(context, 'Orçamento excluído!');
                          // NOTA: A atualização da lista deve ser acionada aqui.
                        } catch (e) {
                          // 2. Verificação de segurança também dentro do catch
                          if (!context.mounted) return;

                          AppFeedback.show(
                            context,
                            'Erro ao excluir: $e',
                            type: FeedbackType.error,
                          );
                        }
                      }
                    }
                  }();
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
