import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../Core/Design/design_system.dart';
import '../../../../Core/Widgets/widgets.dart';
import '../../Orcamento/edita_orcamento.dart';

// **[Propósito]** Componente visual que representa um orçamento no histórico do cliente.
// Destaca visualmente o orçamento mais recente ou itens específicos e disponibiliza opções administrativas (editar/excluir) integradas ao Supabase.
// **[Como usar]** OrcamentoHistoryCard(orcamento: mapDoOrcamento, isLast: true, isHighlight: false, isAdmin: true, onActionCompleted: () => _atualizarLista());
class OrcamentoHistoryCard extends StatelessWidget {
  final Map<String, dynamic> orcamento;
  final bool isLast;
  final bool isHighlight;
  final bool isAdmin;
  final VoidCallback? onActionCompleted;
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
    // **[Extração de Dados]** Mapeamento seguro das propriedades do orçamento
    final titulo = orcamento['titulo'] ?? 'Serviço';
    final valor = orcamento['valor'];
    final dataPega = DateTime.tryParse(orcamento['data_pega'] ?? '');

    // **[Regra de Negócio]** Definição da hierarquia visual (Destaque > Recente > Padrão)
    final Color statusColor = isHighlight
        ? AppColors.adminColor
        : isLast
        ? AppColors.success
        : AppColors.textDisabled;

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceSmall),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        side: isLast || isHighlight
            ? BorderSide(color: statusColor.withValues(alpha: 0.7), width: 1.5)
            : const BorderSide(color: AppColors.borderLight),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spaceSmall,
          horizontal: AppDimensions.spaceLarge,
        ),
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isHighlight ? Icons.star : Icons.build_circle_outlined,
              color: statusColor,
            ),
          ],
        ),
        title: Text(titulo, style: AppTextStyles.bodyMedium),
        subtitle: Row(
          children: [
            if (dataPega != null)
              Text(
                DateFormat('dd/MM/yyyy').format(dataPega),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textDisabled,
                ),
              ),
            const Spacer(),
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
        // **[Ações Administrativas]** Menu renderizado apenas para usuários com permissão (isAdmin)
        trailing: isAdmin
            ? PopupMenuButton<String>(
                onSelected: (choice) async {
                  if (choice == 'editar') {
                    // **[Ação: Editar]** Navega para a tela de edição e aguarda confirmação de mudança
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
                    // **[Ação: Excluir]** Modal de confirmação antes da deleção no banco de dados
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
                        // Deleção remota no Supabase
                        await Supabase.instance.client
                            .from('orcamentos')
                            .delete()
                            .eq('id', orcamento['id']);

                        if (!context.mounted) return;

                        AppFeedback.show(context, 'Orçamento excluído!');
                        onActionCompleted?.call();
                      } catch (e) {
                        if (!context.mounted) return;

                        AppFeedback.show(
                          context,
                          'Erro ao excluir: $e',
                          type: FeedbackType.error,
                        );
                      }
                    }
                  }
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
