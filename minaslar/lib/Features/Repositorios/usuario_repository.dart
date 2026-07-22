import 'package:supabase_flutter/supabase_flutter.dart';
import '../Modelos/usuario_model.dart';

// **[Propósito]** Repositório responsável pela consulta, salvamento, busca por telefone e gerenciamento de cache em RAM dos usuários e técnicos.
// **[Como usar]** final usuarioRepo = UsuarioRepository(); / final tecnicos = await usuarioRepo.listarTodos();
class UsuarioRepository {
  final _supabase = Supabase.instance.client;

  // Gerenciamento de Cache em Memória (RAM)
  static List<Usuario>? _cacheTecnicos;
  static DateTime? _ultimaConsultaCache;
  static const Duration _duracaoCache = Duration(minutes: 10);

  // **[Propósito]** Invalida o cache local em memória para forçar uma nova consulta no banco na próxima requisição.
  void invalidarCache() {
    _cacheTecnicos = null;
    _ultimaConsultaCache = null;
  }

  // **[Propósito]** Busca todos os usuários/técnicos cadastrados, utilizando cache em RAM com validade de 10 minutos para otimizar requisições.
  // **[Parâmetros]** forcarAtualizacao (bool) -> Se verdadeiro, ignora o cache atual e consulta diretamente o Supabase.
  // **[Retorno]** Future<List<Usuario>> -> Lista de usuários ordenados por hierarquia de permissão (administradores primeiro).
  Future<List<Usuario>> listarTodos({bool forcarAtualizacao = false}) async {
    final agora = DateTime.now();

    if (!forcarAtualizacao &&
        _cacheTecnicos != null &&
        _ultimaConsultaCache != null &&
        agora.difference(_ultimaConsultaCache!) < _duracaoCache) {
      return _cacheTecnicos!;
    }

    final resposta = await _supabase
        .from('usuarios')
        .select()
        .order('is_admin', ascending: true);

    final lista = (resposta as List<dynamic>)
        .map((map) => Usuario.fromMap(map as Map<String, dynamic>))
        .toList();

    _cacheTecnicos = lista;
    _ultimaConsultaCache = agora;

    return lista;
  }

  // **[Propósito]** Realiza a busca de um único usuário através do seu número de telefone sanitizado.
  // **[Parâmetros]** telefone (String) -> Número de telefone (com ou sem formatação de caracteres especiais).
  // **[Retorno]** Future<Usuario?> -> Instância do usuário encontrado ou null caso não exista registro.
  Future<Usuario?> buscarPorTelefone(String telefone) async {
    final telefoneLimpo = telefone.replaceAll(RegExp(r'[^0-9]'), '');

    if (telefoneLimpo.isEmpty) return null;

    try {
      final resposta = await _supabase
          .from('usuarios')
          .select()
          .eq('telefone', telefoneLimpo)
          .maybeSingle();

      if (resposta == null) return null;
      return Usuario.fromMap(resposta);
    } catch (_) {
      return null;
    }
  }

  // **[Propósito]** Pesquisa usuários por nome ou telefone com inteligência de filtro local (se houver cache) ou consulta remota resiliente.
  // **[Parâmetros]** termo (String) -> Nome ou número de telefone para filtragem.
  // **[Retorno]** Future<List<Usuario>> -> Lista filtrada contendo até 20 registros compatíveis.
  Future<List<Usuario>> buscarPorNomeOuTelefone(String termo) async {
    final termoLimpo = termo.trim();

    if (termoLimpo.isEmpty) {
      return listarTodos();
    }

    // Filtragem rápida em RAM caso o cache esteja ativo
    if (_cacheTecnicos != null) {
      final termoMinusculo = termoLimpo.toLowerCase();
      final termoNumerico = termoLimpo.replaceAll(RegExp(r'[^0-9]'), '');

      return _cacheTecnicos!.where((u) {
        final matchNome = u.nome.toLowerCase().contains(termoMinusculo);
        final matchTelefone =
            termoNumerico.isNotEmpty && u.telefone.contains(termoNumerico);
        return matchNome || matchTelefone;
      }).toList();
    }

    // Consulta direta ao Supabase caso o cache esteja vazio
    final termoNumerico = termoLimpo.replaceAll(RegExp(r'[^0-9]'), '');
    String filtroOr = "nome.ilike.%$termoLimpo%";

    if (termoNumerico.isNotEmpty) {
      filtroOr += ",telefone.ilike.%$termoNumerico%";
    }

    final resposta = await _supabase
        .from('usuarios')
        .select()
        .or(filtroOr)
        .order('nome', ascending: true)
        .limit(20);

    return (resposta as List<dynamic>)
        .map((map) => Usuario.fromMap(map as Map<String, dynamic>))
        .toList();
  }

  // **[Propósito]** Cadastra ou atualiza as informações do usuário no banco e invalida o cache local automaticamente.
  // **[Parâmetros]** usuario (Usuario) -> Instância do modelo do usuário com os dados a serem salvos.
  Future<void> salvarUsuario(Usuario usuario) async {
    await _supabase.from('usuarios').upsert(usuario.toMap());
    invalidarCache();
  }
}
