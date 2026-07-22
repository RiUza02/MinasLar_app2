import '../../../../Core/Design/design_system.dart';
import '../../HomePage/lista_orcamento.dart';

// **[Propósito]** Cabeçalho de controle para a lista de orçamentos, integrando campo de busca reativo e menu de ordenação.
// **[Como usar]** OrcamentoListHeader(searchController: _controller, sortColumn: _col, sortAscending: true, onSortChanged: (col) => ...);
class OrcamentoListHeader extends StatelessWidget {
  final TextEditingController searchController;
  final OrcamentoSortColumn sortColumn;
  final bool sortAscending;
  final Function(OrcamentoSortColumn?) onSortChanged;

  const OrcamentoListHeader({
    super.key,
    required this.searchController,
    required this.sortColumn,
    required this.sortAscending,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceLarge,
        vertical: AppDimensions.spaceSmall,
      ),
      color: AppColors.cardBackground,
      child: Row(
        children: [
          // **[Campo de Busca Reativo]** Monitora o texto digitado para alternar dinamicamente a exibição do botão de limpar
          Expanded(
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: searchController,
              builder: (context, value, child) {
                return TextField(
                  controller: searchController,
                  style: AppTextStyles.bodyMedium,
                  decoration: InputDecoration(
                    hintText: "Cliente, valor ou data...",
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textDisabled,
                    ),
                    prefixIcon: const Icon(
                      AppIcons.buscar,
                      color: AppColors.textDisabled,
                      size: AppDimensions.iconSizeMedium,
                    ),
                    suffixIcon: value.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              AppIcons.limpar,
                              color: AppColors.textDisabled,
                              size: AppDimensions.iconSizeMedium,
                            ),
                            onPressed: () => searchController.clear(),
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.inputBackground,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.spaceMedium,
                      horizontal: AppDimensions.spaceSmall,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMedium,
                      ),
                      borderSide: const BorderSide(
                        color: AppColors.borderLight,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMedium,
                      ),
                      borderSide: const BorderSide(
                        color: AppColors.borderLight,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMedium,
                      ),
                      borderSide: const BorderSide(
                        color: AppColors.borderFocused,
                        width: 2,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: AppDimensions.spaceSmall),
          _buildSortMenu(context),
        ],
      ),
    );
  }

  // **[Menu de Ordenação]** Exibe as opções de classificação disponíveis e dispara a alteração via callback
  Widget _buildSortMenu(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: PopupMenuButton<OrcamentoSortColumn>(
        icon: const Icon(AppIcons.ordenar, color: AppColors.primary),
        tooltip: "Ordenar orçamentos",
        onSelected: onSortChanged,
        itemBuilder: (context) => [
          _buildSortMenuItem(OrcamentoSortColumn.dataRecente, "Mais Recentes"),
          _buildSortMenuItem(OrcamentoSortColumn.valor, "Valor"),
          _buildSortMenuItem(OrcamentoSortColumn.status, "Status"),
        ],
      ),
    );
  }

  // **[Item de Ordenação]** Renderiza visualmente o estado de seleção do item e o sentido da ordenação (ascendente/descendente)
  PopupMenuItem<OrcamentoSortColumn> _buildSortMenuItem(
    OrcamentoSortColumn value,
    String text,
  ) {
    final isSelected = sortColumn == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            isSelected ? AppIcons.radioChecked : AppIcons.radioUnchecked,
            color: isSelected ? AppColors.primary : AppColors.textDisabled,
            size: AppDimensions.iconSizeMedium,
          ),
          const SizedBox(width: AppDimensions.spaceMedium),
          Text(text, style: AppTextStyles.bodyMedium),
          if (isSelected) ...[
            const Spacer(),
            Icon(
              sortAscending ? AppIcons.arrowUp : AppIcons.arrowDown,
              size: AppDimensions.iconSizeSmall,
              color: AppColors.textSecondary,
            ),
          ],
        ],
      ),
    );
  }
}
