import '../../../../Core/Design/design_system.dart';

/// Barra superior customizada para a tela de configurações.
///
/// [Uso] Este componente substitui a AppBar padrão na tela de ajustes, perfil ou
/// gerenciamento de equipes, centralizando o título da página e fornecendo um
/// botão de ação direta na extremidade direita para realizar o logout do usuário.
class SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Cor de fundo dinâmica que define a identidade visual da barra.
  final Color themeColor;

  /// Ação disparada ao tocar no botão de encerrar sessão (logout).
  final VoidCallback onLogout;

  const SettingsAppBar({
    super.key,
    required this.themeColor,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("Equipe & Perfil"),
      backgroundColor: themeColor,
      foregroundColor: AppColors.textPrimary,
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(AppIcons.logout),
          onPressed: onLogout,
          tooltip: 'Sair do Sistema',
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
