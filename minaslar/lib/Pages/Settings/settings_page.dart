import 'dart:io';
import '../../Core/Design/design_system.dart';
import '../../Core/Errors/errors.dart';
import '../../Core/Services/auth.dart';
import '../../Core/Widgets/widgets.dart';
import '../../Features/Modelos/usuario_model.dart';
import '../../Core/Services/settings_functions.dart';
import 'change_informations.dart';
import 'user_confirmation.dart';
import '../../Core/Widgets/Settings/pending_users_button.dart';
import '../../Core/Widgets/Settings/profile_info_card.dart';
import '../../Core/Widgets/Settings/settings_app_bar.dart';
import '../../Core/Widgets/Settings/users_list_view.dart';

/// [uso] Centraliza as configurações do perfil do usuário logado e a gestão
/// da equipe de funcionários.
///
/// Permite que qualquer usuário edite suas informações básicas (nome e telefone).
/// Se o usuário tiver privilégios administrativos ([isAdmin]), a tela também
/// libera o gerenciamento de convites e aprovação de novos membros na equipe.
class SettingsPage extends StatefulWidget {
  final bool isAdmin;

  const SettingsPage({super.key, required this.isAdmin});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  /// Provedor de funções e lógica de negócios para as configurações.
  final _functions = SettingsFunctions();

  /// Estado de carregamento e controle de exceções da interface.
  bool _isLoading = true;
  bool _isNetworkError = false;
  String _errorMessage = '';

  /// Dados de cache locais dos usuários e da sessão.
  Usuario? _currentUser;
  List<Usuario> _pendingUsers = [];
  List<Usuario> _authenticatedUsers = [];

  @override
  void initState() {
    super.initState();
    _loadData(forceRefresh: false);
  }

  /// Busca os dados da equipe e sincroniza o estado do usuário atual.
  ///
  /// Caso identifique falhas de rede, isola o erro para evitar o logoff.
  /// Em caso de divergência crítica de sessão, força a saída do sistema.
  Future<void> _loadData({bool forceRefresh = false}) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }

    try {
      final data = await _functions.loadData(forceRefresh: forceRefresh);

      if (mounted) {
        setState(() {
          _currentUser = data.currentUser;
          _pendingUsers = data.pendingUsers;
          _authenticatedUsers = data.authenticatedUsers;
          _isNetworkError = false;
        });
      }
    } on SessionDivergenceException catch (e) {
      if (mounted) {
        AppFeedback.show(
          context,
          ErrorHandler.mapearErro(e),
          type: FeedbackType.error,
        );
      }
      await _logout();
    } on NetworkException catch (e) {
      if (mounted) {
        setState(() {
          _isNetworkError = true;
          _errorMessage = ErrorHandler.mapearErro(e);
        });
        AppFeedback.show(context, _errorMessage, type: FeedbackType.error);
      }
    } on SocketException catch (e) {
      if (mounted) {
        setState(() {
          _isNetworkError = true;
          _errorMessage = ErrorHandler.mapearErro(e);
        });
        AppFeedback.show(context, _errorMessage, type: FeedbackType.error);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isNetworkError = false;
          _errorMessage = ErrorHandler.mapearErro(e);
        });
        AppFeedback.show(
          context,
          ErrorHandler.mapearErro(e),
          type: FeedbackType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Salva as alterações de nome e telefone do usuário atual se houver modificações.
  Future<void> _saveProfile({
    required String newName,
    required String newPhone,
  }) async {
    if (_currentUser == null) return;
    FocusScope.of(context).unfocus();

    if (newName == _currentUser!.nome && newPhone == _currentUser!.telefone) {
      if (mounted) {
        AppFeedback.show(context, "Nenhuma alteração foi feita.");
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final updatedUser = await _functions.saveProfile(
        currentUser: _currentUser!,
        newName: newName,
        newPhone: newPhone,
      );

      if (mounted) {
        setState(() => _currentUser = updatedUser);
        AppFeedback.show(
          context,
          "Perfil atualizado com sucesso!",
          type: FeedbackType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.show(
          context,
          ErrorHandler.mapearErro(e),
          type: FeedbackType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Exibe o diálogo para edição do perfil do usuário.
  void _showEditProfileDialog() async {
    if (_currentUser == null) return;

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => ChangeInformationsDialog(currentUser: _currentUser!),
    );

    if (result != null && result.isNotEmpty) {
      await _saveProfile(
        newName: result['nome']!,
        newPhone: result['telefone']!,
      );
    }
  }

  /// Exibe um diálogo de confirmação para revogar o acesso de um usuário.
  void _showRevokeAccessDialog(Usuario userToRevoke) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        ),
        title: const Text('Revogar Acesso'),
        content: Text(
          'Tem certeza que deseja remover o acesso de ${userToRevoke.nome}? O usuário precisará ser aprovado novamente para entrar no sistema.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('REVOGAR'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _revokeUserAccess(userToRevoke);
    }
  }

  /// Revoga o acesso de um usuário e atualiza as listas locais.
  Future<void> _revokeUserAccess(Usuario userToRevoke) async {
    setState(() => _isLoading = true);
    try {
      final revokedUser = await _functions.revokeUserAccess(userToRevoke);
      if (mounted) {
        setState(() {
          _authenticatedUsers.removeWhere((u) => u.id == revokedUser.id);
          _pendingUsers.add(revokedUser);
        });
        AppFeedback.show(
          context,
          'Acesso de ${revokedUser.nome} foi revogado.',
          type: FeedbackType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.show(
          context,
          ErrorHandler.mapearErro(e),
          type: FeedbackType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Exibe a caixa de diálogo com as solicitações de novos membros da equipe.
  void _showPendingUsersDialog() async {
    final Usuario? approvedUser = await showDialog(
      context: context,
      builder: (_) => PendingUsersDialog(
        pendingUsers: _pendingUsers,
        functions: _functions,
      ),
    );

    if (approvedUser != null) {
      setState(() {
        _pendingUsers.removeWhere((u) => u.id == approvedUser.id);
        _authenticatedUsers.add(approvedUser);
        _authenticatedUsers.sort((a, b) {
          if (a.isAdmin && !b.isAdmin) return -1;
          if (!a.isAdmin && b.isAdmin) return 1;
          return a.nome.compareTo(b.nome);
        });
      });
      if (mounted) {
        AppFeedback.show(
          context,
          "${approvedUser.nome} foi permitido no sistema!",
          type: FeedbackType.success,
        );
      }
    }
  }

  /// Encerra a sessão atual limpando o cache persistente e local.
  Future<void> _logout() async {
    setState(() => _isLoading = true);
    await _functions.logout();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthGatePage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.isAdmin
        ? AppColors.primaryAlternative
        : AppColors.primary;

    return Scaffold(
      appBar: SettingsAppBar(themeColor: themeColor, onLogout: _logout),
      floatingActionButton: widget.isAdmin && _pendingUsers.isNotEmpty
          ? PendingUsersButton(
              count: _pendingUsers.length,
              onPressed: _showPendingUsersDialog,
            )
          : null,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: themeColor))
          : _currentUser == null
          ? AppErrorView(
              message: _errorMessage.isNotEmpty
                  ? _errorMessage
                  : "Sessão divergente ou não localizada. Faça login novamente.",
              buttonText: _isNetworkError
                  ? "Tentar Novamente"
                  : "Ir para o Login",
              onTryAgain: _isNetworkError
                  ? () => _loadData(forceRefresh: false)
                  : _logout,
            )
          : RefreshIndicator(
              onRefresh: () => _loadData(forceRefresh: true),
              color: themeColor,
              backgroundColor: AppColors.cardBackground,
              child: ListView(
                padding: const EdgeInsets.all(AppDimensions.spaceLarge),
                children: [
                  ProfileInfoCard(
                    currentUser: _currentUser!,
                    onEdit: _showEditProfileDialog,
                    themeColor: themeColor,
                  ),
                  const SizedBox(height: AppDimensions.spaceXLarge),
                  AppSectionHeader(
                    icon: AppIcons.equipeSection,
                    title: 'EQUIPE AUTENTICADA',
                    count: _authenticatedUsers.length,
                    countLabel: _authenticatedUsers.length == 1
                        ? 'usuário'
                        : 'usuários',
                  ),
                  UsersListView(
                    users: _authenticatedUsers,
                    onUserLongPress: widget.isAdmin
                        ? _showRevokeAccessDialog
                        : null,
                  ),
                ],
              ),
            ),
    );
  }
}
