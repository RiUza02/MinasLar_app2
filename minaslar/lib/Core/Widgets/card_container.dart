import '../Design/design_system.dart';

// **[Propósito]** Container padronizado com cabeçalho (ícone + título) e bordas, ideal para agrupar blocos de informações correlacionadas em formulários e dashboards.
// **[Como usar]** AppCardContainer(titulo: 'DADOS PESSOAIS', icone: Icons.person, children: [TextField(...), ...]);
class AppCardContainer extends StatelessWidget {
  // **[Parâmetros]** titulo (String) -> Texto do cabeçalho; icone (IconData) -> Ícone de identificação visual do bloco.
  final String titulo;
  final IconData icone;

  // **[Parâmetros]** children (List<Widget>) -> Elementos do corpo do card; action (Widget?) -> Ação opcional posicionada no topo direito (ex: botão de editar).
  final List<Widget> children;
  final Widget? action;

  const AppCardContainer({
    super.key,
    required this.titulo,
    required this.icone,
    required this.children,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceLarge),
      // Estrutura visual padronizada consumindo os tokens globais do Design System.
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho superior do card com alinhamento flexível para acomodar o widget de ação opcional.
          Row(
            children: [
              Icon(
                icone,
                color: AppColors.textDisabled,
                size: AppDimensions.iconSizeSmall,
              ),
              const SizedBox(width: AppDimensions.spaceSmall),
              Text(titulo, style: AppTextStyles.cardHeader),
              const Spacer(),
              ?action,
            ],
          ),
          const SizedBox(height: AppDimensions.spaceLarge),
          // Expande os elementos filhos diretamente na coluna do container.
          ...children,
        ],
      ),
    );
  }
}
