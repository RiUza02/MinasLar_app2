import '../../Features/Modelos/usuario_model.dart';
import '../Services/communication.dart';
import '../Utils/formatters.dart';
import '../Design/design_system.dart';

/// Card customizável para exibição de informações cadastrais simplificadas de membros da equipe.
///
/// **[Onde usar]**: Em listas de gerenciamento de equipe, telas de aprovação de novos membros
/// ou painéis administrativos onde seja necessário exibir perfis com ações rápidas de contato.
class UserCard extends StatelessWidget {
  final Usuario user;
  final Widget? trailing;

  const UserCard({super.key, required this.user, this.trailing});

  /// Extrai as iniciais do primeiro e do segundo nome para compor a imagem de placeholder do avatar.
  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(user.nome);
    final bool isUserAdmin = user.isAdmin;

    // Define a cor temática baseada nas permissões de acesso do perfil
    final Color avatarColor = isUserAdmin
        ? AppColors.adminColor
        : AppColors.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceMedium),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceMedium),
        child: Row(
          children: [
            // Placeholder visual circular com as iniciais do usuário
            CircleAvatar(
              radius: 22,
              backgroundColor: avatarColor.withValues(alpha: 0.2),
              child: Text(
                initials,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: avatarColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.spaceMedium),
            // Detalhes textuais identificadores do perfil
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.nome,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Renderiza a tag de destaque caso o usuário possua permissões de admin
                      if (isUserAdmin) ...[
                        const SizedBox(width: AppDimensions.spaceSmall),
                        const _AdminTag(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Telefone formatado visualmente aplicando as máscaras do projeto
                  Text(
                    AppFormatters.telefone.maskText(user.telefone),
                    style: AppTextStyles.bodyMediumSecondary.copyWith(
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.spaceSmall),
            // Injeta o widget de ação customizado ou herda os botões padrões de comunicação
            trailing ?? _buildDefaultActions(context),
          ],
        ),
      ),
    );
  }

  /// Constrói os atalhos nativos para chamadas telefônicas e disparos para o WhatsApp.
  Widget _buildDefaultActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(AppIcons.telefone, color: AppColors.primary),
          onPressed: () => LauncherUtils.fazerLigacao(user.telefone),
          tooltip: 'Ligar',
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(8),
        ),
        const SizedBox(width: AppDimensions.spaceXSmall),
        IconButton(
          icon: const Icon(AppIcons.chat, color: AppColors.success),
          onPressed: () => LauncherUtils.abrirWhatsApp(user.telefone),
          tooltip: 'WhatsApp',
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(8),
        ),
      ],
    );
  }
}

/// Tag interna privada para identificação visual e rotulagem de administradores.
class _AdminTag extends StatelessWidget {
  const _AdminTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceSmall,
        vertical: AppDimensions.spaceXSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.adminColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: AppColors.adminColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        'ADMIN',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.adminColor,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
