import '../../../../Core/Design/design_system.dart';

/// [uso]: Botão flutuante estendido que exibe o número de aprovações pendentes para administradores.
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
