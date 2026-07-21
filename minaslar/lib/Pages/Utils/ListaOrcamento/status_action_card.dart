import '../../../../Core/Design/design_system.dart';
import '../../../../Features/Modelos/orcamento_model.dart';

/// Helper interno para representar cada item de status na interface
class _StatusItem {
  final String label;
  final Color color;
  final IconData icon;

  _StatusItem({required this.label, required this.color, required this.icon});
}

class StatusActionCard extends StatelessWidget {
  final Orcamento orcamento;
  final VoidCallback onStatusChange;

  const StatusActionCard({
    super.key,
    required this.orcamento,
    required this.onStatusChange,
  });

  /// Retorna no máximo 2 status respeitando as regras de prioridade:
  /// - Especial: CONCLUÍDO (sozinho)
  /// - Comum: ATRASADO ou PENDENTE
  /// - Incomum: URGENTE ou GARANTIA
  List<_StatusItem> _obterListaStatus() {
    // 1. STATUS ESPECIAL (Concluído) -> Exibido sozinho com tema azul (AppColors.primary)
    if (orcamento.entregue) {
      return [
        _StatusItem(
          label: "CONCLUÍDO",
          color: AppColors.primary,
          icon: AppIcons.valido,
        ),
      ];
    }

    final List<_StatusItem> lista = [];

    // 2. STATUS COMUM (Atrasado ou Pendente) -> Define o tema amarelo do card
    if (orcamento.isAtrasado) {
      lista.add(
        _StatusItem(
          label: "ATRASADO",
          color: AppColors.warning,
          icon: AppIcons.pendente,
        ),
      );
    } else {
      lista.add(
        _StatusItem(
          label: "PENDENTE",
          color: AppColors.morningShift,
          icon: AppIcons.pendente,
        ),
      );
    }

    // 3. STATUS INCOMUM (Urgente ou Garantia)
    if (orcamento.ehUrgente) {
      lista.add(
        _StatusItem(
          label: "URGENTE",
          color: AppColors.error,
          icon: AppIcons.urgente,
        ),
      );
    } else if (orcamento.ehRetorno) {
      lista.add(
        _StatusItem(
          label: "GARANTIA",
          color: AppColors.adminColor,
          icon: AppIcons.retorno,
        ),
      );
    }

    return lista;
  }

  @override
  Widget build(BuildContext context) {
    final statusList = _obterListaStatus();

    // O status principal (primeiro da lista) dita a cor do fundo e da borda do card
    final corCardPrincipal = statusList.first.color;

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.spaceMedium,
              horizontal: AppDimensions.spaceLarge,
            ),
            decoration: BoxDecoration(
              // EFEITO VISUAL MANTIDO: fundo translúcido + borda colorida referente ao status
              color: corCardPrincipal.withAlpha(38),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              border: Border.all(color: corCardPrincipal),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < statusList.length; i++) ...[
                  if (i > 0) ...[
                    const SizedBox(width: AppDimensions.spaceSmall),
                    const Text(
                      "|",
                      style: TextStyle(color: AppColors.textDisabled),
                    ),
                    const SizedBox(width: AppDimensions.spaceSmall),
                  ],
                  _buildStatusBadge(statusList[i]),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.spaceMedium),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: IconButton(
            icon: const Icon(
              AppIcons.atualizar,
              color: AppColors.textSecondary,
            ),
            tooltip: "Alterar Status",
            onPressed: onStatusChange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(_StatusItem status) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          status.icon,
          color: status.color,
          size: AppDimensions.iconSizeMedium,
        ),
        const SizedBox(width: AppDimensions.spaceXSmall),
        Text(
          status.label,
          style: AppTextStyles.bodyLargeBold.copyWith(color: status.color),
        ),
      ],
    );
  }
}
