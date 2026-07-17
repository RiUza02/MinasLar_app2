import 'package:supabase_flutter/supabase_flutter.dart';
import '../Modelos/usuario_model.dart';

class UsuarioRepository {
  final _supabase = Supabase.instance.client;

  static List<Usuario>? _cacheTecnicos;
  static DateTime? _ultimaConsultaCache;
  static const Duration _duracaoCache = Duration(minutes: 10);

  void invalidarCache() {
    _cacheTecnicos = null;
    _ultimaConsultaCache = null;
  }

  /// Busca todos os técnicos para listagens gerais (com Cache em RAM).
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
        .order('nome', ascending: true);

    // Mapeamento seguro convertendo explicitamente cada item
    final lista = (resposta as List<dynamic>)
        .map((map) => Usuario.fromMap(map as Map<String, dynamic>))
        .toList();

    _cacheTecnicos = lista;
    _ultimaConsultaCache = agora;

    return lista;
  }

  /// Busca um usuário específico pelo telefone limpo.
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

  /// Busca técnicos por Nome ou Telefone com suporte a cache local e busca remota resiliente.
  Future<List<Usuario>> buscarPorNomeOuTelefone(String termo) async {
    final termoLimpo = termo.trim();

    if (termoLimpo.isEmpty) {
      return listarTodos();
    }

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

  /// Salva ou atualiza um técnico e limpa o cache da RAM automaticamente.
  Future<void> salvarUsuario(Usuario usuario) async {
    await _supabase.from('usuarios').upsert(usuario.toMap());
    invalidarCache();
  }
}
