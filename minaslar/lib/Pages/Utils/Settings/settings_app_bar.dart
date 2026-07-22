import '../../../../Core/Design/design_system.dart';

// **[Propósito]** Componente visual de barra superior (AppBar) customizada para a tela de perfil e gerenciamento de equipe. Exibe o título centralizado, aplica dinamicamente a cor de tema da aplicação e disponibiliza uma ação rápida para efetuar o logout do sistema.
// **[Como usar]** SettingsAppBar(themeColor: AppColors.primary, onLogout: () => _efetuarLogout());
class SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color themeColor;
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
  Size get preferredSize => const Size.fromHeight(40.0);
}
