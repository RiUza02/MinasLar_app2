import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../Core/Design_system/design_system.dart';
import '../../Core/Errors/errors_handler.dart';
import '../../Core/Services/auth.dart';
import '../../Core/Utils/formatters.dart';
import '../../Core/Services/communication.dart';
import '../../Core/Widgets/widgets.dart';
import 'user_confirmation.dart';
import '../../Features/Modelos/usuario_model.dart';
import '../../Features/Repositorios/usuario_repository.dart';

/// Tela de Configurações e Gestão de Equipe.
///
/// Permite ao usuário logado editar seus próprios dados (nome e telefone) e,
/// caso possua permissão administrativa (`isAdmin`), gerenciar e aprovar o
/// acesso de novos funcionários no sistema.
class SettingsPage extends StatefulWidget {
  final bool isAdmin;

  const SettingsPage({super.key, required this.isAdmin});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // ==================================================
  // DEPENDÊNCIAS E SERVIÇOS
  // ==================================================
  final _usuarioRepository = UsuarioRepository();
  final _storage = const FlutterSecureStorage();
  final _supabase = Supabase.instance.client;

  // ==================================================
  // ESTADO DA TELA (STATE MANAGEMENT)
  // ==================================================
  bool _isLoading = true;
  Usuario? _currentUser;
  List<Usuario> _pendingUsers = [];
  List<Usuario> _authenticatedUsers = [];

  // ==================================================
  // CONTROLADORES DE TEXTO (CONTROLLERS)
  // ==================================================
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();

  // ==================================================
  // CICLO DE VIDA (LIFECYCLE)
  // ==================================================
  @override
  void initState() {
    super.initState();
    _loadData(forceRefresh: true);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  // ==================================================
  // LÓGICA DE NEGÓCIO E BUSCA DE DADOS (DATA LOGIC)
  // ==================================================

  /// Busca a lista de usuários e resolve a identidade correta da sessão,
  /// normalizando tipos (String vs Int) e formatações de telefone.
  Future<void> _loadData({bool forceRefresh = true}) async {
    if (mounted) setState(() => _isLoading = true);

    try {
      final allUsers = await _usuarioRepository.listarTodos(
        forcarAtualizacao: forceRefresh,
      );

      if (allUsers.isEmpty) {
        _showInfoSnackBar("Nenhum usuário encontrado no banco de dados.");
        return;
      }

      // 1. Coleta IDs e Telefones gravados na sessão (Supabase ou SecureStorage)
      final currentUserId =
          _supabase.auth.currentUser?.id ??
          await _storage.read(key: 'id') ??
          await _storage.read(key: 'user_id') ??
          await _storage.read(key: 'usuario_id');

      final savedPhone =
          await _storage.read(key: 'telefone') ??
          await _storage.read(key: 'phone');
      final cleanPhoneSession = savedPhone?.replaceAll(RegExp(r'[^0-9]'), '');

      // 2. Localiza o usuário logado com comparações à prova de falha de tipos e máscaras
      Usuario? currentUser;
      try {
        currentUser = allUsers.firstWhere((u) {
          // Converte IDs para String pura para evitar que (int == String) retorne false no Dart
          final dbIdStr = u.id.toString().trim();
          final sessionIdStr = currentUserId?.toString().trim();

          final matchById =
              (sessionIdStr != null &&
              sessionIdStr.isNotEmpty &&
              dbIdStr == sessionIdStr);

          // Remove máscaras, espaços e símbolos do telefone vindo do banco de dados
          final dbPhoneClean = u.telefone.replaceAll(RegExp(r'[^0-9]'), '');

          bool matchByPhone = false;
          if (cleanPhoneSession != null && cleanPhoneSession.length >= 8) {
            // Aceita igualdade exata ou sufixos compatíveis para contornar diferenças de DDI (+55)
            matchByPhone =
                (dbPhoneClean == cleanPhoneSession ||
                dbPhoneClean.endsWith(cleanPhoneSession) ||
                cleanPhoneSession.endsWith(dbPhoneClean));
          }

          return matchById || matchByPhone;
        });
      } catch (_) {
        currentUser = null;
      }

      // 3. Se nenhuma conta corresponder exatamente, encerra a sessão com segurança
      if (currentUser == null) {
        _showErrorSnackBar(
          "Sessão divergente ou expirada. Faça login novamente.",
        );
        await _logout();
        return;
      }

      // 4. Separa a equipe e remove o usuário logado da lista para evitar duplicidade
      final otherUsers = allUsers
          .where((u) => u.id != currentUser!.id)
          .toList();

      if (mounted) {
        setState(() {
          _currentUser = currentUser;
          _pendingUsers = otherUsers.where((u) => !u.autenticado).toList();
          _authenticatedUsers = otherUsers.where((u) => u.autenticado).toList();

          _nomeController.text = currentUser!.nome;
          _telefoneController.text = AppFormatters.telefone.maskText(
            currentUser.telefone,
          );
        });
      }
    } catch (e) {
      _showErrorSnackBar(ErrorHandler.mapearErro(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
      final updatedUser = _currentUser!.copyWith(
        nome: nome,
        telefone: telefone,
      );
      await _usuarioRepository.salvarUsuario(updatedUser);

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

  void _showPendingUsersDialog() async {
    final Usuario? approvedUser = await showDialog(
      context: context,
      builder: (_) => PendingUsersDialog(pendingUsers: _pendingUsers),
    );

    if (approvedUser != null) {
      setState(() {
        _pendingUsers.removeWhere((u) => u.id == approvedUser.id);
        _authenticatedUsers.add(approvedUser);
        _authenticatedUsers.sort((a, b) => a.nome.compareTo(b.nome));
      });
      _showSuccessSnackBar("${approvedUser.nome} foi permitido no sistema!");
    }
  }

  /// Desloga limpando o cache da API, do SecureStorage e da memória.
  Future<void> _logout() async {
    setState(() => _isLoading = true);
    try {
      await _supabase.auth.signOut();
    } catch (_) {
      // Ignora exceções caso o login não tenha sido via Supabase Auth nativo
    } finally {
      await _storage.deleteAll();
      _usuarioRepository.invalidarCache();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthGatePage()),
          (route) => false,
        );
      }
    }
  }

  // ==================================================
  // CONSTRUÇÃO DA INTERFACE (UI BUILDERS)
  // ==================================================

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.isAdmin
        ? AppColors.primaryAlternative
        : AppColors.primary;

    return Scaffold(
      appBar: _buildAppBar(themeColor),
      floatingActionButton: widget.isAdmin && _pendingUsers.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _showPendingUsersDialog,
              label: Text('${_pendingUsers.length}'),
              icon: const Icon(Icons.person_add_disabled_outlined),
              backgroundColor: AppColors.primaryAlternative,
              foregroundColor: AppColors.textPrimary,
              tooltip: 'Aprovações Pendentes',
            )
          : null,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: themeColor))
          : _currentUser == null
          ? _buildErrorState()
          : RefreshIndicator(
              onRefresh: () => _loadData(forceRefresh: true),
              color: themeColor,
              backgroundColor: AppColors.cardBackground,
              child: ListView(
                padding: const EdgeInsets.all(AppDimensions.spaceLarge),
                children: [
                  // SECÇÃO 1: Meus Dados (Edição de perfil logado)
                  _buildProfileSection(themeColor),

                  const SizedBox(height: AppDimensions.spaceXLarge),

                  // SECÇÃO 2: Equipe Autenticada (Membros liberados)
                  _buildSectionHeader(
                    icon: Icons.group_outlined,
                    title: 'EQUIPE AUTENTICADA',
                    count: _authenticatedUsers.length,
                  ),
                  _buildUsersList(_authenticatedUsers),
                ],
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(Color themeColor) {
    return AppBar(
      title: const Text("Equipe & Perfil"),
      backgroundColor: themeColor,
      foregroundColor: AppColors.textPrimary,
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: _logout,
          tooltip: 'Sair do Sistema',
        ),
      ],
    );
  }

  Widget _buildProfileSection(Color themeColor) {
    return AppCardContainer(
      icone: AppIcons.dadosPessoaisSection,
      titulo: 'MEUS DADOS',
      children: [
        AppTextField(
          controller: _nomeController,
          label: 'Nome de Usuário',
          icon: AppIcons.nome,
        ),
        const SizedBox(height: AppDimensions.spaceLarge),
        AppTextField(
          controller: _telefoneController,
          label: 'Meu Telefone',
          icon: AppIcons.telefone,
          keyboardType: TextInputType.phone,
          inputFormatters: [AppFormatters.telefone],
        ),
        const SizedBox(height: AppDimensions.spaceXLarge),
        ElevatedButton(
          onPressed: _saveProfile,
          style: ElevatedButton.styleFrom(backgroundColor: themeColor),
          child: const Text('SALVAR ALTERAÇÕES'),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required int count,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppDimensions.spaceMedium,
        left: AppDimensions.spaceSmall,
        right: AppDimensions.spaceSmall,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.textDisabled,
            size: AppDimensions.iconSizeSmall,
          ),
          const SizedBox(width: AppDimensions.spaceSmall),
          Text(title, style: AppTextStyles.cardHeader),
          const Spacer(),
          Text(
            '$count ${count == 1 ? "usuário" : "usuários"}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList(List<Usuario> users) {
    if (users.isEmpty) {
      const msg = "Nenhum outro usuário na equipe.";
      return _buildEmptyListIndicator(msg);
    }

    return Column(children: users.map((user) => _buildUserCard(user)).toList());
  }

  /// Constrói o card utilizando Row + Expanded + Column para evitar o erro
  /// de overflow horizontal causado internamente pelo ListTile no Flutter.
  Widget _buildUserCard(Usuario user) {
    final initials = _getInitials(user.nome);
    final bool isOtherUserAdmin = user.isAdmin;
    final Color avatarColor = isOtherUserAdmin
        ? Colors.amber
        : AppColors.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceMedium),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceMedium),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: avatarColor.withOpacity(0.2),
              child: Text(
                initials,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: avatarColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.spaceMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.nome,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isOtherUserAdmin) ...[
                        const SizedBox(width: AppDimensions.spaceSmall),
                        _buildAdminTag(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.phone, color: AppColors.primary),
                  onPressed: () => LauncherUtils.fazerLigacao(user.telefone),
                  tooltip: 'Ligar',
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.chat, color: Colors.green),
                  onPressed: () => LauncherUtils.abrirWhatsApp(user.telefone),
                  tooltip: 'WhatsApp',
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminTag() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceSmall,
        vertical: AppDimensions.spaceXSmall,
      ),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Text(
        'ADMIN',
        style: AppTextStyles.caption.copyWith(
          color: Colors.amber,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildEmptyListIndicator(String message) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceXLarge),
      margin: const EdgeInsets.only(top: AppDimensions.spaceSmall),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Center(
        child: Text(
          message,
          style: AppTextStyles.bodyMediumSecondary,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: AppDimensions.spaceMedium),
            Text(
              "Sessão divergente ou não localizada. Faça login novamente.",
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spaceLarge),
            ElevatedButton(
              onPressed: _logout,
              child: const Text("Ir para o Login"),
            ),
          ],
        ),
      ),
    );
  }

  // ==================================================
  // MÉTODOS AUXILIARES E SNACKBARS (HELPERS)
  // ==================================================

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.isNotEmpty ? parts[0][0].toUpperCase() : '?';
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
      SnackBar(content: Text(message), backgroundColor: Colors.grey.shade800),
    );
  }
}
