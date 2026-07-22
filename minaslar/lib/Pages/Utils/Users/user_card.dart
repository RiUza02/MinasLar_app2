import '../../../Features/Modelos/usuario_model.dart';
import '../../../Core/Services/communication.dart';
import '../../../Core/Utils/formatters.dart';
import '../../../Core/Design/design_system.dart';

// **[Propósito]** Componente visual em formato de cartão (Card) responsável por exibir as informações de um membro da equipe, gerando automaticamente um avatar com as iniciais do nome. Aplica destaque para administradores e disponibiliza atalhos rápidos nativos para comunicação (ligação e WhatsApp), permitindo também customização do widget final e interações via toque longo.
// **[Como usar]** Padrão: UserCard(user: usuarioDaEquipe); Customizado: UserCard(user: usuario, onLongPress: (u) => _opcoesAdmin(u), trailing: Icon(Icons.check));
class UserCard extends StatelessWidget {
  final Usuario user;
  final Widget? trailing;
  final void Function(Usuario)? onLongPress;

  const UserCard({
    super.key,
    required this.user,
    this.trailing,
    this.onLongPress,
  });

  /// Extrai as iniciais do nome para renderizar no avatar
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

    final Color avatarColor = isUserAdmin
        ? AppColors.adminColor
        : AppColors.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceMedium),
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: InkWell(
        onLongPress: (onLongPress != null && !user.isAdmin)
            ? () => onLongPress!(user)
            : null,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spaceMedium),
          child: Row(
            children: [
              // Avatar com as iniciais do usuário
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
              // Nome, tag de admin e telefone formatado
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
                        if (isUserAdmin) ...[
                          const SizedBox(width: AppDimensions.spaceSmall),
                          const _AdminTag(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
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
              // Ações customizadas ou botões padrão de ligação/WhatsApp
              trailing ?? _buildDefaultActions(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Atalhos nativos para chamadas telefônicas e WhatsApp
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

// **[Propósito]** Componente utilitário privado que renderiza uma etiqueta (badge) para destacar visualmente os usuários que possuem privilégios de administrador na interface.
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
