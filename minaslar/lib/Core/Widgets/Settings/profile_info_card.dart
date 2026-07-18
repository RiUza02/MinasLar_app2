import '../../../../Core/Design/design_system.dart';
import '../../../../Core/Utils/formatters.dart';
import '../../../../Core/Widgets/widgets.dart';
import '../../../../Features/Modelos/usuario_model.dart';

/// Cartão de exibição dos dados de perfil do usuário.
///
/// [Uso] Este componente é utilizado na tela de perfil ou configurações para
/// apresentar as informações cadastrais do usuário (como nome e telefone formatado)
/// de forma agrupada, disponibilizando um botão de ação rápida para edição.
class ProfileInfoCard extends StatelessWidget {
  /// Dados do usuário logado que preencherão o cartão.
  final Usuario currentUser;

  /// Ação disparada ao tocar no botão de edição.
  final VoidCallback onEdit;

  /// Cor dinâmica aplicada ao ícone de edição para respeitar o tema atual.
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
        icon: Icon(Icons.edit_outlined, color: themeColor),
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

/// Linha padronizada para exibição de uma informação específica.
///
/// [Uso] Componente interno privado utilitário para organizar visualmente
/// um ícone alinhado ao lado do rótulo superior (Label) e seu respectivo valor.
class _InfoRow extends StatelessWidget {
  /// Ícone que ilustra o tipo de informação.
  final IconData icon;

  /// Texto do rótulo descritivo (ex: "Nome", "Telefone").
  final String label;

  /// O valor textual do dado a ser exibido.
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
