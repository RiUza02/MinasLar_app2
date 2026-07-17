/// Esta classe é imutável e foi projetada para lidar de forma otimizada com
/// consultas, inserções e modificações contínuas no banco de dados Supabase.
class Cliente {
  /// Identificador único (UUID ou numérico) vindo do banco de dados.
  final String? id;

  /// Nome completo do cliente.
  final String nome;

  /// Nome da rua do endereço.
  final String rua;

  /// Número do imóvel. Mantido como [String] para suportar formatos como "104-B" ou "S/N".
  final String numero;

  /// Complemento do endereço (ex: "Apto 302, Bloco C", "Fundos").
  final String? complemento;

  /// Bairro do endereço do cliente.
  final String bairro;

  /// Número de telefone principal para contato.
  final String telefone;

  /// Cadastro de Pessoa Física (CPF), caso seja pessoa física.
  final String? cpf;

  /// Cadastro Nacional da Pessoa Jurídica (CNPJ), caso seja pessoa jurídica.
  final String? cnpj;

  /// Indicador de risco. Se [true], sinaliza que o cliente possui um histórico
  /// de inadimplência ou problemas contratuais/comportamentais no sistema.
  final bool clienteProblematico;

  /// Anotações gerais, histórico resumido ou preferências do cliente.
  final String? observacao;

  /// Data e hora exatas em que o registro foi criado no banco de dados.
  final DateTime? criadoEm;

  /// Data e hora da última modificação nos dados do cliente.
  /// Fundamental para ordenação cronológica e auditoria de cadastros.
  final DateTime? atualizadoEm;

  /// Construtor principal para criar uma instância imutável de [Cliente].
  const Cliente({
    this.id,
    required this.nome,
    required this.rua,
    required this.numero,
    required this.bairro,
    required this.telefone,
    this.complemento,
    this.cpf,
    this.cnpj,
    this.clienteProblematico = false,
    this.observacao,
    this.criadoEm,
    this.atualizadoEm,
  });

  // ==================================================
  // MÉTODOS DE SERIALIZAÇÃO E OTIMIZAÇÃO (SUPABASE)
  // ==================================================
  /// Converte a instância do objeto [Cliente] em um [Map] compatível com o Supabase.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nome': nome.trim(),
      'rua': rua.trim(),
      'numero': numero.trim(),
      'complemento': complemento?.trim(),
      'bairro': bairro.trim(),
      'observacao': observacao?.trim(),
      'cliente_problematico': clienteProblematico,
      // Converte automaticamente para apenas numeros, removendo espaços, traços e parênteses
      'telefone': telefone.replaceAll(RegExp(r'[^0-9]'), ''),
      'cpf': cpf?.replaceAll(RegExp(r'[^0-9]'), ''),
      'cnpj': cnpj?.replaceAll(RegExp(r'[^0-9]'), ''),
      // Atualiza automaticamente o carimbo de tempo da última modificação
      'atualizado_em': DateTime.now().toIso8601String(),
    };
  }

  /// Cria uma instância de [Cliente] a partir de um [Map] (JSON) retornado pelo Supabase.
  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map['id']?.toString(),
      nome: map['nome'] ?? '',
      rua: map['rua'] ?? '',
      numero: map['numero']?.toString() ?? '',
      complemento: map['complemento'],
      bairro: map['bairro'] ?? '',
      telefone: map['telefone'] ?? '',
      cpf: map['cpf'],
      cnpj: map['cnpj'],
      clienteProblematico: map['cliente_problematico'] ?? false,
      observacao: map['observacao'],
      criadoEm: map['criado_em'] != null
          ? DateTime.tryParse(map['criado_em'].toString())
          : null,
      atualizadoEm: map['atualizado_em'] != null
          ? DateTime.tryParse(map['atualizado_em'].toString())
          : null,
    );
  }

  // ==================================================
  // MÉTODOS DE CÓPIA E COMPARAÇÃO DE ESTADO
  // ==================================================
  /// Cria uma cópia da instância atual de [Cliente], permitindo a alteração
  /// de campos específicos de forma imutável (essencial para gerência de estado).
  Cliente copyWith({
    String? id,
    String? nome,
    String? rua,
    String? numero,
    String? complemento,
    String? bairro,
    String? telefone,
    String? cpf,
    String? cnpj,
    bool? clienteProblematico,
    String? observacao,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return Cliente(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      rua: rua ?? this.rua,
      numero: numero ?? this.numero,
      complemento: complemento ?? this.complemento,
      bairro: bairro ?? this.bairro,
      telefone: telefone ?? this.telefone,
      cpf: cpf ?? this.cpf,
      cnpj: cnpj ?? this.cnpj,
      clienteProblematico: clienteProblematico ?? this.clienteProblematico,
      observacao: observacao ?? this.observacao,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  /// Compara a igualdade estrutural dos objetos em vez da referência na memória.
  /// Evita que a interface (UI) reconstrua widgets sem necessidade.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Cliente &&
        other.id == id &&
        other.nome == nome &&
        other.rua == rua &&
        other.numero == numero &&
        other.complemento == complemento &&
        other.bairro == bairro &&
        other.telefone == telefone &&
        other.cpf == cpf &&
        other.cnpj == cnpj &&
        other.clienteProblematico == clienteProblematico &&
        other.observacao == observacao &&
        other.criadoEm == criadoEm &&
        other.atualizadoEm == atualizadoEm;
  }

  /// Gera um hash único para o conteúdo do objeto. Essencial para performance
  /// rápida ao armazenar clientes em estruturas como [Set] ou chaves de [Map].
  @override
  int get hashCode {
    return Object.hash(
      id,
      nome,
      rua,
      numero,
      complemento,
      bairro,
      telefone,
      cpf,
      cnpj,
      clienteProblematico,
      observacao,
      Object.hash(criadoEm, atualizadoEm),
    );
  }
}
