import '../../../../Core/Design/design_system.dart';
import '../../HomePage/lista_cliente.dart'; // For ClienteSortColumn
import 'cliente_search_bar.dart';

/// [uso] Cabeçalho da lista de clientes, contendo a barra de busca e o menu de ordenação.
class ClienteListHeader extends StatelessWidget {
  final TextEditingController searchController;
  final ClienteSortColumn sortColumn;
  final bool sortAscending;
  final Function(ClienteSortColumn?) onSortChanged;

  const ClienteListHeader({
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
          Expanded(child: ClienteSearchBar(controller: searchController)),
          const SizedBox(width: AppDimensions.spaceSmall),
          _buildSortMenu(context),
        ],
      ),
    );
  }

  Widget _buildSortMenu(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: PopupMenuButton<ClienteSortColumn>(
        icon: const Icon(Icons.sort, color: AppColors.primary),
        tooltip: "Ordenar clientes",
        onSelected: onSortChanged,
        itemBuilder: (context) => [
          _buildSortMenuItem(
            ClienteSortColumn.ultimoAtendimento,
            "Último Atendimento",
          ),
          _buildSortMenuItem(ClienteSortColumn.nome, "Nome (A-Z)"),
          _buildSortMenuItem(ClienteSortColumn.rua, "Rua (A-Z)"),
          _buildSortMenuItem(ClienteSortColumn.bairro, "Bairro (A-Z)"),
        ],
      ),
    );
  }

  PopupMenuItem<ClienteSortColumn> _buildSortMenuItem(
    ClienteSortColumn value,
    String text,
  ) {
    final isSelected = sortColumn == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            isSelected
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            color: isSelected ? AppColors.primary : AppColors.textDisabled,
            size: AppDimensions.iconSizeMedium,
          ),
          const SizedBox(width: AppDimensions.spaceMedium),
          Text(text, style: AppTextStyles.bodyMedium),
          if (isSelected) ...[
            const Spacer(),
            Icon(
              sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              size: AppDimensions.iconSizeSmall,
              color: AppColors.textSecondary,
            ),
          ],
        ],
      ),
    );
  }
}
