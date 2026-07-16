/// Modelo que representa um técnico ou usuário administrativo da loja.
/// Projetado para altíssima taxa de leitura.
class Usuario {
  /// Identificador único (UUID) vinculado ao Supabase.
  final String? id;

  /// Nome completo do técnico ou funcionário.
  final String nome;

  /// Telefone de contato (armazenado apenas números no banco).
  final String telefone;

  /// Define se o usuário possui permissões administrativas na loja.
  final bool isAdmin;

  /// Data de cadastro no sistema.
  final DateTime? criadoEm;

  /// Data da última modificação cadastral.
  final DateTime? atualizadoEm;

  /// Construtor principal imutável.
  const Usuario({
    this.id,
    required this.nome,
    required this.telefone,
    this.isAdmin = false,
    this.criadoEm,
    this.atualizadoEm,
  });

  // ==================================================
  // MÉTODOS DE SERIALIZAÇÃO (SUPABASE)
  // ==================================================

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nome': nome.trim(),
      'telefone': telefone.replaceAll(RegExp(r'[^0-9]'), ''),
      'is_admin': isAdmin,
      'atualizado_em': DateTime.now().toIso8601String(),
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id']?.toString(),
      nome: map['nome'] ?? '',
      telefone: map['telefone'] ?? '',
      isAdmin: map['is_admin'] ?? false,
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

  Usuario copyWith({
    String? id,
    String? nome,
    String? telefone,
    bool? isAdmin,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return Usuario(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      telefone: telefone ?? this.telefone,
      isAdmin: isAdmin ?? this.isAdmin,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  /// Sobrescreve o operador de igualdade (`==`).
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Usuario &&
        other.id == id &&
        other.nome == nome &&
        other.telefone == telefone &&
        other.isAdmin == isAdmin &&
        other.criadoEm == criadoEm &&
        other.atualizadoEm == atualizadoEm;
  }

  /// Sobrescreve o gerador de Hash do objeto.
  @override
  int get hashCode {
    return Object.hash(id, nome, telefone, isAdmin, criadoEm, atualizadoEm);
  }

  /// Retorna uma representação em texto limpa do objeto.
  @override
  String toString() {
    return 'Usuario(id: $id, nome: $nome, telefone: $telefone, isAdmin: $isAdmin)';
  }
}
