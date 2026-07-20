import '../../Core/Design/design_system.dart';
import '../../Core/Errors/errors.dart';
import '../../Core/Widgets/widgets.dart';
import '../../Features/Modelos/usuario_model.dart';
import '../Utils/Settings/settings_functions.dart';

/// [uso]: Diálogo modal para listar e aprovar usuários com cadastro pendente.
class PendingUsersDialog extends StatefulWidget {
  final List<Usuario> pendingUsers;
  final SettingsFunctions functions;

  const PendingUsersDialog({
    super.key,
    required this.pendingUsers,
    required this.functions,
  });

  @override
  State<PendingUsersDialog> createState() => _PendingUsersDialogState();
}

class _PendingUsersDialogState extends State<PendingUsersDialog> {
  bool _isApproving = false;

  /// [uso]: Modifica o status do usuário para aprovado e fecha o modal retornando o objeto atualizado.
  Future<void> _approveUser(Usuario userToApprove) async {
    setState(() => _isApproving = true);
    try {
      final approvedUser = await widget.functions.approveUser(userToApprove);
      if (mounted) {
        // Retorna o usuário aprovado para atualização do estado na tela pai
        Navigator.of(context).pop(approvedUser);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        _showErrorSnackBar(ErrorHandler.mapearErro(e));
      }
    } finally {
      if (mounted) setState(() => _isApproving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      title: const Text('Aprovações Pendentes'),
      content: SizedBox(
        width: double.maxFinite,
        child: _isApproving ? _buildLoadingIndicator() : _buildUsersList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('FECHAR'),
        ),
      ],
    );
  }

  /// [uso]: Exibe um indicador de carregamento durante o processo de aprovação.
  Widget _buildLoadingIndicator() {
    return const Center(
      heightFactor: 2,
      child: CircularProgressIndicator(color: AppColors.primaryAlternative),
    );
  }

  /// [uso]: Constrói a lista com os cartões dos usuários pendentes de aprovação.
  Widget _buildUsersList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.pendingUsers.length,
      itemBuilder: (context, index) {
        final user = widget.pendingUsers[index];
        return UserCard(
          user: user,
          trailing: ElevatedButton(
            onPressed: () => _approveUser(user),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spaceMedium,
              ),
              minimumSize: const Size(0, 36),
            ),
            child: const Text('Permitir'),
          ),
        );
      },
    );
  }

  /// [uso]: Exibe uma notificação de erro no rodapé em caso de falha na requisição.
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }
}
