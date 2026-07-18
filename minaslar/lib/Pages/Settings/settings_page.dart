import 'dart:io';
import '../../Core/Design/design_system.dart';
import '../../Core/Errors/errors.dart';
import '../../Core/Services/auth.dart';
import '../../Core/Utils/formatters.dart';
import '../../Core/Widgets/widgets.dart';
import '../../Features/Modelos/usuario_model.dart';
import '../../Core/Services/settings_functions.dart';
import 'user_confirmation.dart';

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

  /// Controladores de entrada de texto do formulário de perfil.
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData(forceRefresh: false);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    super.dispose();
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

          _nomeController.text = data.currentUser.nome;
          _telefoneController.text = AppFormatters.telefone.maskText(
            data.currentUser.telefone,
          );
        });
      }
    } on SessionDivergenceException catch (e) {
      _showErrorSnackBar(ErrorHandler.mapearErro(e));
      await _logout();
    } on NetworkException catch (e) {
      if (mounted) {
        setState(() {
          _isNetworkError = true;
          _errorMessage = ErrorHandler.mapearErro(e);
        });
        _showErrorSnackBar(_errorMessage);
      }
    } on SocketException catch (e) {
      if (mounted) {
        setState(() {
          _isNetworkError = true;
          _errorMessage = ErrorHandler.mapearErro(e);
        });
        _showErrorSnackBar(_errorMessage);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isNetworkError = false;
          _errorMessage = ErrorHandler.mapearErro(e);
        });
        _showErrorSnackBar(_errorMessage);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Salva as alterações de nome e telefone do usuário atual se houver modificações.
  Future<void> _saveProfile() async {
    if (_currentUser == null) return;
    FocusScope.of(context).unfocus();

    final nome = _nomeController.text.trim();
    final telefone = AppFormatters.telefone.unmaskText(
      _telefoneController.text,
    );

    if (nome == _currentUser!.nome && telefone == _currentUser!.telefone) {
      _showInfoSnackBar("Nenhuma alteração foi feita.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedUser = await _functions.saveProfile(
        currentUser: _currentUser!,
        newName: nome,
        newPhone: telefone,
      );

      if (mounted) {
        setState(() => _currentUser = updatedUser);
        _showSuccessSnackBar("Perfil atualizado com sucesso!");
      }
    } catch (e) {
      _showErrorSnackBar(ErrorHandler.mapearErro(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Exibe a caixa de diálogo com as solicitações de novos membros da equipe.
  void _showPendingUsersDialog() async {
    final Usuario? approvedUser = await showDialog(
      context: context,
      builder: (_) => PendingUsersDialog(pendingUsers: _pendingUsers),
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
      _showSuccessSnackBar("${approvedUser.nome} foi permitido no sistema!");
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
      appBar: _SettingsAppBar(themeColor: themeColor, onLogout: _logout),
      floatingActionButton: widget.isAdmin && _pendingUsers.isNotEmpty
          ? _PendingUsersButton(
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
                  _ProfileSection(
                    nomeController: _nomeController,
                    telefoneController: _telefoneController,
                    onSave: _saveProfile,
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
                  _UsersListView(users: _authenticatedUsers),
                ],
              ),
            ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.success),
    );
  }

  void _showInfoSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.textDisabled),
    );
  }
}

/// Barra superior personalizada com botão integrado de saída.
class _SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color themeColor;
  final VoidCallback onLogout;

  const _SettingsAppBar({required this.themeColor, required this.onLogout});

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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Botão flutuante para administradores gerenciarem entradas pendentes.
class _PendingUsersButton extends StatelessWidget {
  final int count;
  final VoidCallback onPressed;

  const _PendingUsersButton({required this.count, required this.onPressed});

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

/// Cartão contendo o formulário de edição de dados básicos do perfil.
class _ProfileSection extends StatelessWidget {
  final TextEditingController nomeController;
  final TextEditingController telefoneController;
  final VoidCallback onSave;
  final Color themeColor;

  const _ProfileSection({
    required this.nomeController,
    required this.telefoneController,
    required this.onSave,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppCardContainer(
      icone: AppIcons.dadosPessoaisSection,
      titulo: 'MEUS DADOS',
      children: [
        AppTextField(
          controller: nomeController,
          label: 'Nome de Usuário',
          icon: AppIcons.nome,
        ),
        const SizedBox(height: AppDimensions.spaceLarge),
        AppTextField(
          controller: telefoneController,
          label: 'Meu Telefone',
          icon: AppIcons.telefone,
          keyboardType: TextInputType.phone,
          inputFormatters: [AppFormatters.telefone],
        ),
        const SizedBox(height: AppDimensions.spaceXLarge),
        ElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(backgroundColor: themeColor),
          child: const Text('SALVAR ALTERAÇÕES'),
        ),
      ],
    );
  }
}

/// Lista reativa que mapeia e exibe os cartões da equipe autenticada.
class _UsersListView extends StatelessWidget {
  final List<Usuario> users;

  const _UsersListView({required this.users});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const AppEmptyListIndicator(
        message: "Nenhum outro usuário na equipe.",
      );
    }
    return Column(children: users.map((user) => UserCard(user: user)).toList());
  }
}
