  // ===========================================================================
  // SERVIÇO DE VERIFICAÇÃO DE CLIENTE DUPLICADO
  // ===========================================================================
  static Future<Cliente?> verificarClienteDuplicado({
    required String nome,
    required String rua,
    required String numero,
  }) async {
    if (nome.trim().isEmpty || rua.trim().isEmpty || numero.trim().isEmpty) {
      return null;
    }

    final primeiroNome = nome.trim().split(' ').first;

    try {
      final response = await Supabase.instance.client
          .from('clientes')
          .select()
          .ilike('nome', '$primeiroNome%')
          .ilike('rua', rua.trim())
          .limit(1)
          .maybeSingle();

      if (response != null) {
        return Cliente.fromMap(response);
      }

      return null;
    } catch (e) {
      debugPrint("Erro ao verificar cliente duplicado: $e");
      return null;
    }
  }