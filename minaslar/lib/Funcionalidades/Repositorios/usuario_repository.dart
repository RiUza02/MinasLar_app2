import 'package:supabase_flutter/supabase_flutter.dart';
import '../Modelos/usuario_model.dart';

class UsuarioRepository {
  final _supabase = Supabase.instance.client;

  // ==================================================
  // CACHE EM MEMÓRIA (Otimização para Alta Leitura)
  // ==================================================
  static List<Usuario>? _cacheTecnicos;
  static DateTime? _ultimaConsultaCache;

  /// Tempo de validade do cache (ex: 10 minutos).
  /// Como funcionários raramente mudam, isso evita 99% dos requests HTTP da sua loja.
  static const Duration _duracaoCache = Duration(minutes: 10);

  /// Limpa o cache manualmente (chame isso sempre que salvar ou editar um técnico)
  void invalidarCache() {
    _cacheTecnicos = null;
    _ultimaConsultaCache = null;
  }

  /// Busca todos os técnicos para listagens gerais (com Cache em RAM).
  /// Correção: O parâmetro 'forcarAtualizacao' agora está sem o caractere especial 'ç'.
  Future<List<Usuario>> listarTodos({bool forcarAtualizacao = false}) async {
    final agora = DateTime.now();

    // 1. Se o cache for válido e não forçamos atualização, retorna da memória em 0ms
    if (!forcarAtualizacao &&
        _cacheTecnicos != null &&
        _ultimaConsultaCache != null &&
        agora.difference(_ultimaConsultaCache!) < _duracaoCache) {
      return _cacheTecnicos!;
    }

    // 2. Se não tem cache, busca do Supabase com ordenação alfabética
    final resposta = await _supabase
        .from('usuarios')
        .select()
        .order('nome', ascending: true);

    final lista = (resposta as List<dynamic>)
        .map((map) => Usuario.fromMap(map as Map<String, dynamic>))
        .toList();

    // 3. Salva na RAM e carimba o horário
    _cacheTecnicos = lista;
    _ultimaConsultaCache = agora;

    return lista;
  }

  /// Busca técnicos por Nome ou Telefone (com suporte a busca parcial na digitação).
  Future<List<Usuario>> buscarPorNomeOuTelefone(String termo) async {
    final termoLimpo = termo.trim();

    // Se a busca estiver vazia, usa o cache local para listar todos!
    if (termoLimpo.isEmpty) {
      return listarTodos();
    }

    // Se o cache já existe na RAM, podemos filtrar LOCALMENTE sem gastar requisição!
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

    // Se não há cache, vai ao Supabase usando os índices GIN de Trigramas do SQL
    final termoNumerico = termoLimpo.replaceAll(RegExp(r'[^0-9]'), '');
    String filtroOr = 'nome.ilike.%$termoLimpo%';

    if (termoNumerico.isNotEmpty) {
      filtroOr += ',telefone.ilike.%$termoNumerico%';
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

  /// Salva ou atualiza um técnico e limpa o cache da RAM automaticamente.
  Future<void> salvarUsuario(Usuario usuario) async {
    await _supabase.from('usuarios').upsert(usuario.toMap());

    // Essencial: ao modificar um dado raro, destruímos o cache da memória
    // para que a próxima leitura traga a versão nova do Supabase.
    invalidarCache();
  }
}
