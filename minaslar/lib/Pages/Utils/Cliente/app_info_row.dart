import '../../../Core/Design/design_system.dart';

/// [uso] Exibe uma linha de informações no padrão "ícone + rótulo + valor".
/// Pode incluir uma ação opcional e suporte a pressionamento longo.
class AppInfoRow extends StatelessWidget {
  /// Ícone exibido ao lado da informação.
  final IconData icon;

  /// Nome do campo.
  final String label;

  /// Valor exibido.
  final String value;

  /// Define se o conteúdo deve ser alinhado para múltiplas linhas.
  final bool isMultiline;

  /// Ação executada ao manter o item pressionado.
  final VoidCallback? onLongPress;

  /// Ícone da ação opcional.
  final IconData? actionIcon;

  /// Ação executada ao tocar no ícone.
  final VoidCallback? onActionTap;

  /// Cor do ícone de ação.
  final Color? actionIconColor;

  const AppInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.isMultiline = false,
    this.onLongPress,
    this.actionIcon,
    this.onActionTap,
    this.actionIconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      // Permite efeito visual do InkWell.
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      child: InkWell(
        // Aciona evento de pressionamento longo.
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: Container(
          // Espaçamento interno do componente.
          padding: const EdgeInsets.all(AppDimensions.spaceLarge),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            // Borda padrão do card.
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            // Ajusta alinhamento para textos longos.
            crossAxisAlignment: isMultiline
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              // Ícone da informação.
              Icon(
                icon,
                color: AppColors.textDisabled,
                size: AppDimensions.iconSize,
              ),
              const SizedBox(width: AppDimensions.spaceMedium),

              // Área de texto.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rótulo do campo.
                    Text(label.toUpperCase(), style: AppTextStyles.overline),
                    const SizedBox(height: AppDimensions.spaceXSmall),

                    // Valor da informação.
                    Text(
                      value,
                      style: AppTextStyles.bodyMedium.copyWith(height: 1.4),
                    ),
                  ],
                ),
              ),

              // Exibe botão de ação caso informado.
              if (actionIcon != null)
                IconButton(
                  onPressed: onActionTap,
                  icon: Icon(
                    actionIcon,
                    color: actionIconColor ?? AppColors.primary,
                  ),
                  tooltip: 'Abrir no Mapa',
                ),
            ],
          ),
        ),
      ),
    );
  }
}
