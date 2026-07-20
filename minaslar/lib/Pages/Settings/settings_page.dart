import 'dart:io';
import '../../Core/Design/design_system.dart';
import '../../Core/Errors/errors.dart';
import '../../Core/Services/auth.dart';
import '../../Core/Widgets/widgets.dart';
import '../../Features/Modelos/usuario_model.dart';
import '../Utils/Settings/settings_functions.dart';
import 'change_informations.dart';
import 'user_confirmation.dart';
import '../Utils/Settings/pending_users_button.dart';
import '../Utils/Settings/settings_app_bar.dart';
import '../Utils/Settings/settings_body.dart';

/// [uso]: Centraliza as configurações do perfil do usuário e o gerenciamento de membros da equipe.
class SettingsPage extends StatefulWidget {
  final bool isAdmin;

  const SettingsPage({super.key, required this.isAdmin});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _functions = SettingsFunctions();

  // Controle de estado e exceções
  bool _isLoading = true;
  String _errorMessage = '';

  // Estado local dos usuários
  Usuario? _currentUser;
  List<Usuario> _pendingUsers = [];
  List<Usuario> _authenticatedUsers = [];

  @override
  void initState() {
    super.initState();
    _loadData(forceRefresh: false);
  }

  /// Carrega os dados da equipe e sincroniza a sessão do usuário atual
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
          _errorMessage = ErrorHandler.mapearErro(e);
        });
        AppFeedback.show(context, _errorMessage, type: FeedbackType.error);
      }
    } on SocketException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = ErrorHandler.mapearErro(e);
        });
        AppFeedback.show(context, _errorMessage, type: FeedbackType.error);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
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

  /// Salva as alterações cadastrais de nome e telefone do perfil
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

  /// Exibe o diálogo para edição das informações do perfil
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

  /// Exibe a caixa de confirmação antes de revogar o acesso de um usuário
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

  /// Revoga o acesso do usuário selecionado e reordena as listas locais
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

  /// Exibe o diálogo para aprovação de solicitações pendentes
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

  /// Processa o logout e redireciona o fluxo para a tela de autenticação
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
      body: SettingsBody(
        isLoading: _isLoading,
        currentUser: _currentUser,
        authenticatedUsers: _authenticatedUsers,
        errorMessage: _errorMessage,
        isAdmin: widget.isAdmin,
        themeColor: themeColor,
        onRefresh: () => _loadData(forceRefresh: true),
        onTryAgain: () => _loadData(forceRefresh: false),
        onEditProfile: _showEditProfileDialog,
        onUserLongPress: _showRevokeAccessDialog,
      ),
    );
  }
}
