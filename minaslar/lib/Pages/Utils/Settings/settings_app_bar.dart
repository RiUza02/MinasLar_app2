import '../../../../Core/Design/design_system.dart';

/// [uso]: Barra superior customizada para a tela de configurações e perfil de equipe.
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
