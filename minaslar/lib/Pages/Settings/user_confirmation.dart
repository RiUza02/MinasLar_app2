import '../../Core/Design/design_system.dart';
import '../../Core/Errors/errors.dart';
import '../../Core/Widgets/widgets.dart';
import '../../Features/Modelos/usuario_model.dart';
import '../Utils/Settings/settings_functions.dart';

// **[Propósito]** Diálogo modal para listar e aprovar usuários com cadastro pendente, exclusivo para administradores.
// **[Como usar]** final Usuario? approvedUser = await showDialog(context: context, builder: (_) => PendingUsersDialog(pendingUsers: list, functions: controller));
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

  // **[Ação: Aprovar Usuário]** Modifica o status do usuário para aprovado via backend e fecha o modal, retornando o objeto atualizado para sincronização de estado na tela chamadora.
  Future<void> _approveUser(Usuario userToApprove) async {
    setState(() => _isApproving = true);
    try {
      final approvedUser = await widget.functions.approveUser(userToApprove);
      if (mounted) {
        // Retorna o usuário aprovado para atualização imediata do estado na tela pai
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
        // Altera para o indicador de progresso para evitar múltiplos toques acidentais
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

  // **[Estado Visual: Carregando]** Exibe um indicador de progresso limpo e centralizado enquanto a requisição de aprovação está em andamento.
  Widget _buildLoadingIndicator() {
    return const Center(
      heightFactor: 2,
      child: CircularProgressIndicator(color: AppColors.primaryAlternative),
    );
  }

  // **[Subcomponente: Lista]** Constrói a lista dinâmica com os cartões dos usuários aguardando aprovação, embutindo um botão de ação "Permitir" em cada item.
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

  // **[Feedback Visual]** Exibe um alerta de erro isolado no rodapé da aplicação caso a aprovação não possa ser concluída.
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }
}
