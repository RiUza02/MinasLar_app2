import '../../../../Core/Design/design_system.dart';

// **[Propósito]** Componente visual (FloatingActionButton estendido) focado em administradores, utilizado para alertar visualmente sobre a quantidade de usuários aguardando aprovação no sistema e fornecer acesso rápido a essa lista.
// **[Como usar]** PendingUsersButton(count: 5, onPressed: () => _abrirTelaDeAprovacoes());
class PendingUsersButton extends StatelessWidget {
  final int count;
  final VoidCallback onPressed;

  const PendingUsersButton({
    super.key,
    required this.count,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      label: Text('$count'),
      icon: const Icon(AppIcons.aprovacoesPendentes),
      backgroundColor: AppColors.primaryAlternative,
      foregroundColor: AppColors.textPrimary,
      tooltip: 'Aprovações Pendentes',
    );
  }
}
