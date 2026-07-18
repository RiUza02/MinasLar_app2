import '../../Core/Design/design_system.dart';
import '../../Core/Errors/errors.dart';
import '../../Core/Widgets/widgets.dart';
import '../../Features/Modelos/usuario_model.dart';
import '../../Features/Repositorios/usuario_repository.dart';

/// [uso] Diálogo modal interativo utilizado para listar e aprovar funcionários
/// que estão com o cadastro pendente de liberação no sistema.
///
/// Exibe os dados básicos do usuário e disponibiliza uma ação rápida para
/// conceder o acesso definitivo.
class PendingUsersDialog extends StatefulWidget {
  final List<Usuario> pendingUsers;

  const PendingUsersDialog({super.key, required this.pendingUsers});

  @override
  State<PendingUsersDialog> createState() => _PendingUsersDialogState();
}

class _PendingUsersDialogState extends State<PendingUsersDialog> {
  /// Repositório para gerenciamento e persistência dos dados de usuários.
  final _usuarioRepository = UsuarioRepository();

  /// Controla o estado de carregamento durante a requisição de aprovação.
  bool _isApproving = false;

  /// Modifica o status do funcionário para autenticado e fecha o modal em caso de sucesso.
  Future<void> _approveUser(Usuario userToApprove) async {
    setState(() => _isApproving = true);
    try {
      final approvedUser = userToApprove.copyWith(autenticado: true);
      await _usuarioRepository.salvarUsuario(approvedUser);

      if (mounted) {
        // Retorna o usuário aprovado para que a tela principal atualize a lista local.
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

  /// Exibe um indicador de progresso centralizado durante a comunicação com o repositório.
  Widget _buildLoadingIndicator() {
    return const Center(
      heightFactor: 2,
      child: CircularProgressIndicator(color: AppColors.primaryAlternative),
    );
  }

  /// Monta a listagem dinâmica contendo os cartões dos usuários pendentes.
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

  /// Exibe um alerta visual na parte inferior da interface caso ocorra alguma falha.
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }
}
