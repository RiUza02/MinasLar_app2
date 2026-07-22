import '../../../../Core/Design/design_system.dart';
import '../../../../Core/Utils/formatters.dart';
import '../../../../Features/Modelos/cliente_model.dart';

// **[Propósito]** Componente visual (Card) utilizado em listagens para exibir o resumo dos dados de um cliente. Apresenta informações como nome, telefone formatado, endereço, data do último serviço e destaca visualmente clientes marcados como problemáticos.
// **[Como usar]** ClienteCard(cliente: modeloCliente, onTap: () => _abrirDetalhes());
class ClienteCard extends StatelessWidget {
  final Cliente cliente;
  final VoidCallback onTap;

  const ClienteCard({super.key, required this.cliente, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isProblematic = cliente.clienteProblematico;
    final statusColor = isProblematic ? AppColors.error : AppColors.primary;
    final address = '${cliente.rua}, ${cliente.numero} - ${cliente.bairro}'
        .trim();

    // Formatação da data do último serviço
    String dataUltimoServico = 'Sem registro anterior';
    if (cliente.ultimoOrcamento != null &&
        cliente.ultimoOrcamento!.isNotEmpty) {
      final parsedDate = DateTime.tryParse(cliente.ultimoOrcamento!);
      if (parsedDate != null) {
        dataUltimoServico =
            '${parsedDate.day.toString().padLeft(2, '0')}/${parsedDate.month.toString().padLeft(2, '0')}/${parsedDate.year}';
      } else {
        dataUltimoServico = 'Data indisponível';
      }
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceSmall),
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spaceMedium),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Ícone e tag indicativa de alerta
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isProblematic) ...[
                    _buildUrgenteTag(),
                    const SizedBox(height: AppDimensions.spaceXSmall),
                  ],
                  Icon(
                    AppIcons.clientes,
                    color: statusColor,
                    size: AppDimensions.spaceXXXLarge,
                  ),
                ],
              ),
              const SizedBox(width: AppDimensions.spaceMedium),
              // Dados do cliente: nome, telefone, endereço e último serviço
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cliente.nome,
                      style: AppTextStyles.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.spaceXSmall),
                    Text(
                      AppFormatters.telefone.maskText(cliente.telefone),
                      style: AppTextStyles.bodyMediumSecondary,
                    ),
                    const SizedBox(height: AppDimensions.spaceXSmall),
                    Text(
                      address.isEmpty ? 'Endereço não informado' : address,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textDisabled,
                        fontWeight: FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.spaceSmall),
                    Row(
                      children: [
                        const Icon(
                          AppIcons.historico,
                          size: AppDimensions.iconSizeXSmall,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppDimensions.spaceXSmall),
                        Text(
                          'Último serviço: $dataUltimoServico',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(AppIcons.navegar, color: AppColors.textDisabled),
            ],
          ),
        ),
      ),
    );
  }

  // **[Propósito]** Constrói a tag (selo) visual de alerta indicando que o cliente está marcado como problemático, aplicando as cores e estilos de erro do design system.
  Widget _buildUrgenteTag() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceSmall,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.5)),
      ),
      child: Text(
        'PROBLEMA',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.error,
          fontWeight: FontWeight.bold,
          fontSize: 6,
        ),
      ),
    );
  }
}
