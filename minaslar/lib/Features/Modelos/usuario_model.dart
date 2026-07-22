// **[Propósito]** Entidade imutável que representa um técnico ou usuário administrativo da loja, com foco em segurança e alta taxa de leitura.
// **[Como usar]** final usuario = Usuario.fromMap(jsonSupabase); / final payload = usuario.toMap();
class Usuario {
  final String? id;
  final String nome;
  final String telefone;
  final bool isAdmin;
  final bool autenticado;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  const Usuario({
    this.id,
    required this.nome,
    required this.telefone,
    this.isAdmin = false,
    this.autenticado = false,
    this.criadoEm,
    this.atualizadoEm,
  });

  // ==================================================
  // MÉTODOS DE SERIALIZAÇÃO (SUPABASE)
  // ==================================================

  // **[Propósito]** Converte a instância de [Usuario] em um Map serializável para persistência no banco de dados.
  // **[Retorno]** Map<String, dynamic> -> Estrutura de dados tratada (com sanitização do telefone).
  // **[Como usar]** await supabase.from('usuarios').upsert(usuario.toMap());
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nome': nome.trim(),
      'telefone': telefone.replaceAll(RegExp(r'[^0-9]'), ''),
      'is_admin': isAdmin,
      'autenticado': autenticado,
      'atualizado_em': DateTime.now().toIso8601String(),
    };
  }

  // **[Propósito]** Factory constructor que desserializa os dados do Supabase em uma instância do tipo [Usuario].
  // **[Parâmetros]** map (Map<String, dynamic>) -> Dados de entrada retornados da consulta SQL.
  // **[Retorno]** Usuario -> Instância configurada com tratamentos para valores nulos.
  // **[Como usar]** final usuario = Usuario.fromMap(response.data.first);
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id']?.toString(),
      nome: map['nome'] ?? '',
      telefone: map['telefone']?.toString() ?? '',
      isAdmin: map['is_admin'] ?? false,
      autenticado: map['autenticado'] ?? false,
      criadoEm: map['criado_em'] != null
          ? DateTime.tryParse(map['criado_em'].toString())
          : null,
      atualizadoEm: map['atualizado_em'] != null
          ? DateTime.tryParse(map['atualizado_em'].toString())
          : null,
    );
  }

  // ==================================================
  // MÉTODOS DE CÓPIA E COMPARAÇÃO
  // ==================================================

  // **[Propósito]** Cria uma nova instância de [Usuario] preservando a imutabilidade e alterando apenas os atributos especificados.
  // **[Como usar]** final usuarioAprovado = usuario.copyWith(autenticado: true);
  Usuario copyWith({
    String? id,
    String? nome,
    String? telefone,
    bool? isAdmin,
    bool? autenticado,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return Usuario(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      telefone: telefone ?? this.telefone,
      isAdmin: isAdmin ?? this.isAdmin,
      autenticado: autenticado ?? this.autenticado,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  // **[Propósito]** Compara se dois usuários possuem o mesmo conteúdo comparando todos os atributos individualmente.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Usuario &&
        other.id == id &&
        other.nome == nome &&
        other.telefone == telefone &&
        other.isAdmin == isAdmin &&
        other.autenticado == autenticado &&
        other.criadoEm == criadoEm &&
        other.atualizadoEm == atualizadoEm;
  }

  // **[Propósito]** Gera o código hash numérico do objeto baseado em suas propriedades para otimização em listas e mapas.
  @override
  int get hashCode {
    return Object.hash(
      id,
      nome,
      telefone,
      isAdmin,
      autenticado,
      criadoEm,
      atualizadoEm,
    );
  }

  // **[Propósito]** Retorna a representação textual do objeto para facilitar o debugging e logs do sistema.
  @override
  String toString() {
    return 'Usuario(id: $id, nome: $nome, telefone: $telefone, isAdmin: $isAdmin, autenticado: $autenticado)';
  }
}
