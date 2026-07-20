import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../Core/Errors/exceptions.dart';
import '../../../Features/Modelos/usuario_model.dart';
import '../../../Features/Repositorios/usuario_repository.dart';

/// [uso]: Modelo container para agrupar os dados carregados na tela de configurações.
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

/// [uso]: Concentra as regras de negócio, ordenação e chamadas de repositório da tela de configurações.
class SettingsFunctions {
  final _usuarioRepository = UsuarioRepository();
  final _storage = const FlutterSecureStorage();

  /// [uso]: Carrega as informações do usuário atual e separa os demais usuários entre ativos e pendentes.
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

  /// [uso]: Atualiza o nome e o telefone do usuário logado no repositório.
  Future<Usuario> saveProfile({
    required Usuario currentUser,
    required String newName,
    required String newPhone,
  }) async {
    final updatedUser = currentUser.copyWith(nome: newName, telefone: newPhone);
    await _usuarioRepository.salvarUsuario(updatedUser);
    return updatedUser;
  }

  /// [uso]: Limpa o armazenamento local do dispositivo e invalida o cache em memória do repositório.
  Future<void> logout() async {
    await _storage.deleteAll();
    _usuarioRepository.invalidarCache();
  }

  /// [uso]: Aprova o cadastro de um usuário tornando-o autenticado no sistema.
  Future<Usuario> approveUser(Usuario userToApprove) async {
    final approvedUser = userToApprove.copyWith(autenticado: true);
    await _usuarioRepository.salvarUsuario(approvedUser);
    return approvedUser;
  }

  /// [uso]: Revoga as permissões de um usuário, alterando seu status para não autenticado.
  Future<Usuario> revokeUserAccess(Usuario userToRevoke) async {
    final revokedUser = userToRevoke.copyWith(autenticado: false);
    await _usuarioRepository.salvarUsuario(revokedUser);
    return revokedUser;
  }
}
