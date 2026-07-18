import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../Errors/exceptions.dart';
import '../../Features/Modelos/usuario_model.dart';
import '../../Features/Repositorios/usuario_repository.dart';

/// Modelo para agrupar os dados carregados para a tela de configurações.
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

/// Classe que encapsula a lógica de negócio da tela de configurações.
class SettingsFunctions {
  final _usuarioRepository = UsuarioRepository();
  final _storage = const FlutterSecureStorage();

  /// [Uso] Carrega as informações necessárias para a tela de configurações,
  /// identificando o usuário logado e separando os demais entre ativos e pendentes.
  Future<SettingsData> loadData({bool forceRefresh = true}) async {
    // Busca todos os usuários do banco
    final allUsers = await _usuarioRepository.listarTodos(
      forcarAtualizacao: forceRefresh,
    );

    // Valida se a tabela possui registros
    if (allUsers.isEmpty) {
      throw ValidationException("Nenhum usuário encontrado no banco de dados.");
    }

    // Recupera as credenciais locais salvas no dispositivo
    final currentUserId = await _storage.read(key: 'id');
    final savedPhone = await _storage.read(key: 'telefone');
    final cleanPhoneSession = savedPhone?.replaceAll(RegExp(r'[^0-9]'), '');

    Usuario? currentUser;
    try {
      // Encontra o usuário logado por ID ou Telefone exato
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
      currentUser = null; // Usuário não localizado
    }

    // Se as credenciais locais não baterem com nenhuma conta, desloga por segurança
    if (currentUser == null) {
      throw const SessionDivergenceException();
    }

    // Filtra os outros usuários ignorando a si mesmo
    final otherUsers = allUsers.where((u) => u.id != currentUser!.id).toList();

    // Filtra e ordena a lista de usuários autenticados:
    // 1. Administradores primeiro.
    // 2. Em seguida, por ordem alfabética de nome.
    final authenticated = otherUsers.where((u) => u.autenticado).toList()
      ..sort((a, b) {
        if (a.isAdmin && !b.isAdmin) return -1; // a (admin) vem antes de b
        if (!a.isAdmin && b.isAdmin) return 1; // b (admin) vem antes de a
        return a.nome.compareTo(b.nome); // critério de desempate
      });

    // Retorna os dados agrupados por status de autenticação
    return SettingsData(
      currentUser: currentUser,
      pendingUsers: otherUsers.where((u) => !u.autenticado).toList(),
      authenticatedUsers: authenticated,
    );
  }

  /// [Uso] Atualiza os dados cadastrais (nome e telefone) do usuário atual no banco de dados.
  Future<Usuario> saveProfile({
    required Usuario currentUser,
    required String newName,
    required String newPhone,
  }) async {
    // Cria uma cópia alterada do modelo de usuário
    final updatedUser = currentUser.copyWith(nome: newName, telefone: newPhone);

    // Envia a atualização para o repositório
    await _usuarioRepository.salvarUsuario(updatedUser);
    return updatedUser;
  }

  /// [Uso] Encerra a sessão do usuário atual limpando os dados salvos localmente e os caches de memória.
  Future<void> logout() async {
    // Apaga chaves locais (ID, Telefone, Senha) do aparelho
    await _storage.deleteAll();

    // Limpa a memória volátil do repositório
    _usuarioRepository.invalidarCache();
  }
}
