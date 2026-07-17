import 'package:flutter/material.dart';

import '../../Core/Design_system/design_system.dart';
import '../../Core/Errors/errors_handler.dart';
import '../../Core/Utils/formatters.dart';
import '../../Features/Modelos/usuario_model.dart';
import '../../Features/Repositorios/usuario_repository.dart';

/// Diálogo modal para exibir e aprovar usuários com acesso pendente.
class PendingUsersDialog extends StatefulWidget {
  final List<Usuario> pendingUsers;

  const PendingUsersDialog({super.key, required this.pendingUsers});

  @override
  State<PendingUsersDialog> createState() => _PendingUsersDialogState();
}

class _PendingUsersDialogState extends State<PendingUsersDialog> {
  // ==================================================
  // DEPENDÊNCIAS E SERVIÇOS
  // ==================================================
  final _usuarioRepository = UsuarioRepository();

  // ==================================================
  // ESTADO DA TELA (STATE MANAGEMENT)
  // ==================================================
  bool _isApproving = false;

  // ==================================================
  // LÓGICA DE NEGÓCIO E BUSCA DE DADOS (DATA LOGIC)
  // ==================================================

  /// Libera o acesso de um funcionário e fecha o diálogo em caso de sucesso.
  Future<void> _approveUser(Usuario userToApprove) async {
    setState(() => _isApproving = true);
    try {
      final approvedUser = userToApprove.copyWith(autenticado: true);
      await _usuarioRepository.salvarUsuario(approvedUser);

      if (mounted) {
        // Retorna o usuário aprovado para a tela anterior atualizar o estado.
        Navigator.of(context).pop(approvedUser);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Fecha o diálogo em caso de erro.
        _showErrorSnackBar(ErrorHandler.mapearErro(e));
      }
    } finally {
      if (mounted) setState(() => _isApproving = false);
    }
  }

  // ==================================================
  // CONSTRUÇÃO DA INTERFACE (UI BUILDERS)
  // ==================================================

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      title: const Text('Aprovações Pendentes'),
      content: SizedBox(
        width: double.maxFinite, // Garante que o diálogo ocupe a largura ideal
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

  /// Exibe um indicador de carregamento durante o processamento da aprovação.
  Widget _buildLoadingIndicator() {
    return const Center(
      heightFactor: 2,
      child: CircularProgressIndicator(color: AppColors.primaryAlternative),
    );
  }

  /// Constrói a lista de cartões para cada usuário pendente.
  Widget _buildUsersList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.pendingUsers.length,
      itemBuilder: (context, index) {
        final user = widget.pendingUsers[index];
        return _UserCardDialog(user: user, onApprove: () => _approveUser(user));
      },
    );
  }

  // ==================================================
  // MÉTODOS AUXILIARES E SNACKBARS (HELPERS)
  // ==================================================

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }
}

/// Widget de card de usuário otimizado para uso dentro de um diálogo.
///
/// Utiliza o padrão Row + Expanded + Column para impedir que o título colida
/// visualmente com o botão de aprovação em telas estreitas.
class _UserCardDialog extends StatelessWidget {
  final Usuario user;
  final VoidCallback onApprove;

  const _UserCardDialog({required this.user, required this.onApprove});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.inputBackground,
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceMedium),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceSmall),
        child: Row(
          children: [
            // 1. ESQUERDA/CENTRO: Nome e Telefone do usuário
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.nome,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
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

            // 2. DIREITA: Botão de aprovação
            ElevatedButton(
              onPressed: onApprove,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceMedium,
                ),
                minimumSize: const Size(0, 36),
              ),
              child: const Text('Permitir'),
            ),
          ],
        ),
      ),
    );
  }
}
