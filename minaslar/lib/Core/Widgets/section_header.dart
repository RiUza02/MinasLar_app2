import '../Design/design_system.dart';

// **[Propósito]** Cabeçalho estruturado para listagens, combinando ícone, título e um contador opcional para quantificar os dados.
// **[Como usar]** AppSectionHeader(icon: Icons.people, title: 'Equipe', count: 5, countLabel: 'Usuários');
class AppSectionHeader extends StatelessWidget {
  // **[Parâmetros]** icon (IconData) -> Ícone de identificação visual; title (String) -> Nome da seção (ex: "Pendentes").
  final IconData icon;
  final String title;

  // **[Parâmetros]** count (int?) -> Número de itens na lista; countLabel (String?) -> Rótulo do contador (ex: "itens", "orçamentos").
  final int? count;
  final String? countLabel;

  const AppSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.count,
    this.countLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppDimensions.spaceMedium,
        left: AppDimensions.spaceSmall,
        right: AppDimensions.spaceSmall,
      ),
      child: Row(
        children: [
          // Ícone ilustrativo de identificação da seção com tonalidade neutra.
          Icon(
            icon,
            color: AppColors.textDisabled,
            size: AppDimensions.iconSizeSmall,
          ),
          const SizedBox(width: AppDimensions.spaceSmall),
          // Título principal consumindo a tipografia padrão de cabeçalho do Design System.
          Text(title, style: AppTextStyles.cardHeader),
          const Spacer(),
          // Renderiza o indicador quantitativo à direita apenas se o número e o rótulo forem fornecidos.
          if (count != null && countLabel != null)
            Text(
              '$count $countLabel',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textDisabled,
              ),
            ),
        ],
      ),
    );
  }
}
