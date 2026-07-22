import '../../../../Core/Design/design_system.dart';
import '../../HomePage/lista_cliente.dart';
import 'cliente_search_bar.dart';

// **[Propósito]** Componente visual que atua como cabeçalho da lista de clientes, agrupando de forma alinhada a barra de pesquisa textual e o menu de ordenação dos resultados.
// **[Como usar]** ClienteListHeader(searchController: _controller, sortColumn: _currentSort, sortAscending: _isAscending, onSortChanged: (newSort) => _updateSort(newSort));
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

  // **[Propósito]** Constrói o botão e o menu suspenso (dropdown) contendo as opções de critérios de ordenação da lista de clientes (ex: Último Atendimento, Nome, Rua, Bairro).
  Widget _buildSortMenu(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: PopupMenuButton<ClienteSortColumn>(
        icon: const Icon(AppIcons.ordenar, color: AppColors.primary),
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

  // **[Propósito]** Constrói individualmente os itens do menu de ordenação, destacando visualmente qual é a opção ativa (com ícone e cor) e indicando se a ordem atual é crescente ou decrescente.
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
