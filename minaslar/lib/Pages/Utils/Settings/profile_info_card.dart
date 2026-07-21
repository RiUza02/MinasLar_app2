import '../../../../Core/Design/design_system.dart';
import '../../../../Core/Utils/formatters.dart';
import '../../../../Core/Widgets/widgets.dart';
import '../../../../Features/Modelos/usuario_model.dart';

/// [uso]: Cartão de exibição das informações cadastrais do perfil do usuário logado.
class ProfileInfoCard extends StatelessWidget {
  final Usuario currentUser;
  final VoidCallback onEdit;
  final Color themeColor;

  const ProfileInfoCard({
    super.key,
    required this.currentUser,
    required this.onEdit,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppCardContainer(
      icone: AppIcons.dadosPessoaisSection,
      titulo: 'MEUS DADOS',
      action: IconButton(
        icon: Icon(AppIcons.editar, color: themeColor),
        onPressed: onEdit,
        tooltip: 'Editar Perfil',
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
      children: [
        _InfoRow(icon: AppIcons.nome, label: 'Nome', value: currentUser.nome),
        const SizedBox(height: AppDimensions.spaceLarge),
        _InfoRow(
          icon: AppIcons.telefone,
          label: 'Telefone',
          value: AppFormatters.telefone.maskText(currentUser.telefone),
        ),
      ],
    );
  }
}

/// [uso]: Componente utilitário privado para organizar uma linha com ícone, rótulo e valor.
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColors.textDisabled,
          size: AppDimensions.iconSizeMedium,
        ),
        const SizedBox(width: AppDimensions.spaceMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textDisabled,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceXSmall),
              Text(value, style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
