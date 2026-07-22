import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../Core/Errors/exceptions.dart';
import '../../../Features/Modelos/usuario_model.dart';
import '../../../Features/Repositorios/usuario_repository.dart';

// **[Propósito]** Modelo de dados (Container) utilizado para agrupar e transportar o estado completo necessário para a tela de configurações, incluindo o usuário atual logado, a lista de usuários pendentes de aprovação e a equipe já autenticada.
// **[Como usar]** Retornado por funções de carregamento para popular a interface: SettingsData(currentUser: user, pendingUsers: pendentes, authenticatedUsers: equipe);
class SettingsData {
  final Usuario currentUser;
  final List<Usuario> pendingUsers;
  final List<Usuario> authenticatedUsers;

  SettingsData({
    required this.currentUser,
    required this.pendingUsers,
    required this.authenticatedUsers,
  });
}

// **[Propósito]** Classe de serviço (Controller de regras de negócio) que centraliza a lógica, ordenação, integrações com repositórios e acesso ao armazenamento local para a tela de configurações. Gerencia a sessão do usuário e ações administrativas sobre a equipe.
// **[Como usar]** Instanciada na camada de gerência de estado para executar operações de negócio. Ex: final functions = SettingsFunctions(); final data = await functions.loadData();
class SettingsFunctions {
  final _usuarioRepository = UsuarioRepository();
  final _storage = const FlutterSecureStorage();

  // **[Propósito]** Carrega as informações de todos os usuários, identifica o perfil do usuário logado cruzando dados da sessão local com o banco, e separa os demais usuários em listas de pendentes e ativos (ordenando administradores primeiro, seguidos de ordem alfabética).
  Future<SettingsData> loadData({bool forceRefresh = true}) async {
    final allUsers = await _usuarioRepository.listarTodos(
      forcarAtualizacao: forceRefresh,
    );

    if (allUsers.isEmpty) {
      throw ValidationException("Nenhum usuário encontrado no banco de dados.");
    }

    final currentUserId = await _storage.read(key: 'id');
    final savedPhone = await _storage.read(key: 'telefone');
    final cleanPhoneSession = savedPhone?.replaceAll(RegExp(r'[^0-9]'), '');

    Usuario? currentUser;
    try {
      // Localiza o usuário logado via ID local ou telefone cadastrado
      currentUser = allUsers.firstWhere((u) {
        final dbIdStr = u.id.toString().trim();
        final sessionIdStr = currentUserId?.toString().trim();
        final matchById =
            (sessionIdStr != null &&
            sessionIdStr.isNotEmpty &&
            dbIdStr == sessionIdStr);

        final dbPhoneClean = u.telefone.replaceAll(RegExp(r'[^0-9]'), '');
        final matchByPhone =
            (cleanPhoneSession != null && dbPhoneClean == cleanPhoneSession);

        return matchById || matchByPhone;
      });
    } catch (e) {
      currentUser = null;
    }

    // Exceção disparada caso as credenciais locais não correspondam a nenhum cadastro ativo
    if (currentUser == null) {
      throw const SessionDivergenceException();
    }

    // Filtra os usuários excluindo o próprio perfil
    final otherUsers = allUsers.where((u) => u.id != currentUser!.id).toList();

    // Ordena usuários autenticados: administradores no topo, seguidos por ordem alfabética
    final authenticated = otherUsers.where((u) => u.autenticado).toList()
      ..sort((a, b) {
        if (a.isAdmin && !b.isAdmin) return -1;
        if (!a.isAdmin && b.isAdmin) return 1;
        return a.nome.compareTo(b.nome);
      });

    return SettingsData(
      currentUser: currentUser,
      pendingUsers: otherUsers.where((u) => !u.autenticado).toList(),
      authenticatedUsers: authenticated,
    );
  }

  // **[Propósito]** Atualiza o nome e o telefone do perfil do usuário logado e persiste essas alterações no repositório.
  Future<Usuario> saveProfile({
    required Usuario currentUser,
    required String newName,
    required String newPhone,
  }) async {
    final updatedUser = currentUser.copyWith(nome: newName, telefone: newPhone);
    await _usuarioRepository.salvarUsuario(updatedUser);
    return updatedUser;
  }

  // **[Propósito]** Limpa completamente os dados de sessão do dispositivo no armazenamento seguro e invalida o cache em memória, efetivando a saída do usuário.
  Future<void> logout() async {
    await _storage.deleteAll();
    _usuarioRepository.invalidarCache();
  }

  // **[Propósito]** Aprova o cadastro de um usuário da equipe, alterando seu status para autenticado e salvando-o no banco de dados.
  Future<Usuario> approveUser(Usuario userToApprove) async {
    final approvedUser = userToApprove.copyWith(autenticado: true);
    await _usuarioRepository.salvarUsuario(approvedUser);
    return approvedUser;
  }

  // **[Propósito]** Revoga o acesso de um usuário previamente autorizado, alterando seu status para não autenticado e salvando a alteração.
  Future<Usuario> revokeUserAccess(Usuario userToRevoke) async {
    final revokedUser = userToRevoke.copyWith(autenticado: false);
    await _usuarioRepository.salvarUsuario(revokedUser);
    return revokedUser;
  }
}
