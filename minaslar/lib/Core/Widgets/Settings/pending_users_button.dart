import '../../../../Core/Design/design_system.dart';

/// Botão flutuante para gerenciamento de aprovações.
///
/// [Uso] Este componente é utilizado como um atalho visual (Floating Action Button)
/// para exibir a quantidade de novos usuários aguardando validação e direcionar
/// o administrador para a tela de gerenciamento de entradas.
class PendingUsersButton extends StatelessWidget {
  /// Quantidade atual de aprovações pendentes.
  final int count;

  /// Ação disparada ao pressionar o botão.
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
