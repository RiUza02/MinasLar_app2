import 'package:intl/intl.dart';
import '../../../../Core/Design/design_system.dart';
import '../../../../Features/Modelos/orcamento_model.dart';

class OrcamentoCard extends StatelessWidget {
  final Orcamento orcamento;
  final bool isAdmin;
  final VoidCallback onTap;

  const OrcamentoCard({
    super.key,
    required this.orcamento,
    required this.isAdmin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Formatação de Dados
    final dataEntradaF = DateFormat('dd/MM/yy').format(orcamento.dataPega);
    final dataEntregaF = orcamento.dataEntrega != null
        ? DateFormat('dd/MM/yy').format(orcamento.dataEntrega!)
        : '--/--';
    final valorF = orcamento.valor != null
        ? NumberFormat.currency(
            locale: 'pt_BR',
            symbol: 'R\$',
          ).format(orcamento.valor)
        : 'A Combinar';

    // 2. Lógica de Status (Rigorosamente na ordem das 6 prioridades)
    String statusText;
    Color statusColor;
    Color borderColor;

    final hoje = DateUtils.dateOnly(DateTime.now());
    final dataEntregaDateOnly = orcamento.dataEntrega != null
        ? DateUtils.dateOnly(orcamento.dataEntrega!)
        : null;

    final isAtrasado =
        !orcamento.entregue &&
        dataEntregaDateOnly != null &&
        dataEntregaDateOnly.isBefore(hoje);

    if (!orcamento.entregue && orcamento.ehUrgente) {
      // 1º: Urgente, não entregue, retorno ou não -> Vermelho
      statusText = "URGENTE";
      statusColor = Colors.red;
      borderColor = Colors.red;
    } else if (!orcamento.entregue && isAtrasado) {
      // 2º: Atrasado, não entregue, retorno ou não -> Laranja
      statusText = "ATRASADO";
      statusColor = Colors.orange;
      borderColor = Colors.orange;
    } else if (!orcamento.entregue && orcamento.ehRetorno) {
      // 3º: Retorno (Garantia), não entregue -> Verde
      statusText = "GARANTIA";
      statusColor = Colors.green;
      borderColor = Colors.green;
    } else if (!orcamento.entregue && dataEntregaDateOnly != null) {
      // 4º: Em prazo (não entregue) -> Azul
      statusText = "PENDENTE";
      statusColor = Colors.blue;
      borderColor = Colors.blue;
    } else if (orcamento.entregue) {
      // 5º: Entregue -> Azul (Título riscado)
      statusText = "CONCLUÍDO";
      statusColor = Colors.blue;
      borderColor = Colors.blue;
    } else {
      // 6º: Sem data (não entregue) -> Cinza
      statusText = "SEM DATA";
      statusColor = Colors.grey;
      borderColor = Colors.grey;
    }

    final clienteNome = (orcamento.cliente?.nome ?? 'Cliente não encontrado');

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            border: Border(left: BorderSide(color: borderColor, width: 5)),
          ),
          padding: const EdgeInsets.all(AppDimensions.spaceLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatusTag(text: statusText, color: statusColor),
                  _DateInfo(
                    entrada: dataEntradaF,
                    entrega: dataEntregaF,
                    isAtrasado: isAtrasado,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spaceMedium),
              Text(
                orcamento.titulo,
                style: AppTextStyles.titleMedium.copyWith(
                  // Aplica o risco no título caso o orçamento seja do 5º nível (Entregue)
                  decoration: orcamento.entregue
                      ? TextDecoration.lineThrough
                      : null,
                  color: orcamento.entregue
                      ? AppColors.textDisabled
                      : AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppDimensions.spaceSmall),
              Row(
                children: [
                  Icon(
                    AppIcons.cliente,
                    size: AppDimensions.iconSizeSmall,
                    color: AppColors.textDisabled,
                  ),
                  const SizedBox(width: AppDimensions.spaceSmall),
                  Expanded(
                    child: Text(
                      clienteNome,
                      style: AppTextStyles.bodyMediumSecondary,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (isAdmin) ...[
                const Divider(
                  height: AppDimensions.spaceXLarge,
                  color: AppColors.borderLight,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    valorF,
                    style: AppTextStyles.bodyLargeBold.copyWith(
                      color: orcamento.valor != null
                          ? AppColors.adminColor
                          : AppColors.textDisabled,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  final String text;
  final Color color;
  const _StatusTag({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceSmall,
        vertical: AppDimensions.spaceXSmall,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(color: color, letterSpacing: 0.5),
      ),
    );
  }
}

class _DateInfo extends StatelessWidget {
  final String entrada;
  final String entrega;
  final bool isAtrasado;
  const _DateInfo({
    required this.entrada,
    required this.entrega,
    required this.isAtrasado,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          AppIcons.calendario,
          size: 12,
          color: AppColors.textDisabled,
        ),
        const SizedBox(width: 4),
        Text(
          entrada,
          style: AppTextStyles.caption.copyWith(color: AppColors.textDisabled),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Icon(
            Icons.arrow_forward,
            size: 12,
            color: AppColors.textDisabled,
          ),
        ),
        const Icon(AppIcons.evento, size: 12, color: AppColors.textDisabled),
        const SizedBox(width: 4),
        Text(
          entrega,
          style: AppTextStyles.caption.copyWith(
            color: isAtrasado ? Colors.orange : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
