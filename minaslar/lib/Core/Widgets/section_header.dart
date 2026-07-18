import '../Design/design_system.dart';

/// Cabeçalho estruturado para seções, exibindo um ícone, título e um contador opcional à direita.
///
/// **[Onde usar]**: No topo de listagens em geral para agrupar e quantificar dados semanticamente.
/// Exemplos: Cabeçalhos como "Equipe (5 Usuários)", "Pendentes (2)", etc.
class AppSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
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
          // Ícone identificador sutil da seção
          Icon(
            icon,
            color: AppColors.textDisabled,
            size: AppDimensions.iconSizeSmall,
          ),
          const SizedBox(width: AppDimensions.spaceSmall),
          // Título textual da seção baseado nos estilos do Design System
          Text(title, style: AppTextStyles.cardHeader),
          const Spacer(),
          // Se houver contador e rótulo, exibe-os alinhados à direita da linha
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
