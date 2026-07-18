import '../Design/design_system.dart';

/// Container card com cabeçalho (ícone + título), bordas e espaçamentos padronizados.
///
/// **[Onde usar]**: Ideal para agrupar blocos de informações correlacionadas.
/// Exemplos: Card de "Dados Pessoais", Card de "Segurança" ou seções de formulários.
class AppCardContainer extends StatelessWidget {
  /// Título em destaque no topo da seção do card (ex: "DADOS PESSOAIS").
  final String titulo;

  /// Ícone que acompanha o título para rápida identificação visual da seção.
  final IconData icone;

  /// Lista de widgets (geralmente campos de texto ou botões) que ficarão dentro do card.
  final List<Widget> children;

  const AppCardContainer({
    super.key,
    required this.titulo,
    required this.icone,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceLarge),
      // Estrutura visual baseada nos tokens do Design System
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho padronizado (Ícone + Título)
          Row(
            children: [
              Icon(
                icone,
                color: AppColors.textDisabled,
                size: AppDimensions.iconSizeSmall,
              ),
              const SizedBox(width: AppDimensions.spaceSmall),
              Text(titulo, style: AppTextStyles.cardHeader),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceLarge),
          // Injeção da lista de elementos internos do card
          ...children,
        ],
      ),
    );
  }
}
