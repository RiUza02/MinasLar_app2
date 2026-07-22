import '../../../Core/Design/design_system.dart';

// **[Propósito]** Componente visual de UI (Widget) que exibe uma linha de informação padronizada contendo ícone principal, rótulo e valor. Suporta formatação em múltiplas linhas, ação secundária em botão lateral e evento de pressionamento longo (long press).
// **[Como usar]** AppInfoRow(icon: Icons.phone, label: 'Telefone', value: '32 98888-8888', onLongPress: () => copiar(), actionIcon: Icons.map);
class AppInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isMultiline;
  final VoidCallback? onLongPress;
  final IconData? actionIcon;
  final VoidCallback? onActionTap;
  final Color? actionIconColor;

  // **[Propósito]** Inicializa o componente estrutural requerendo os dados visuais essenciais (ícone, rótulo, valor) e oferecendo opções de customização para ações.
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
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      child: InkWell(
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.spaceLarge),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            crossAxisAlignment: isMultiline
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: AppColors.textDisabled,
                size: AppDimensions.iconSize,
              ),
              const SizedBox(width: AppDimensions.spaceMedium),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label.toUpperCase(), style: AppTextStyles.overline),
                    const SizedBox(height: AppDimensions.spaceXSmall),
                    Text(
                      value,
                      style: AppTextStyles.bodyMedium.copyWith(height: 1.4),
                    ),
                  ],
                ),
              ),

              if (actionIcon != null)
                IconButton(
                  onPressed: onActionTap,
                  icon: Icon(
                    actionIcon,
                    color: actionIconColor ?? AppColors.primary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
