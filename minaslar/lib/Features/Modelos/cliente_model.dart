/// Classe imutável da entidade Cliente.
class Cliente {
  final String? id;
  final String nome;
  final String rua;
  final String numero;
  final String? complemento;
  final String bairro;
  final String telefone;
  final String? cpf;
  final String? cnpj;
  final bool clienteProblematico;
  final String? observacao;
  final DateTime? criadoEm;
  final String? ultimoOrcamento; // Data do serviço ou ID associado

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
    this.ultimoOrcamento,
  });

  // ==================================================
  // SERIALIZAÇÃO
  // ==================================================

  /// [uso]: Prepara os dados do cliente para salvar ou atualizar no Supabase/Banco de Dados.
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
      // Salva apenas os números no banco
      'telefone': _limparNumeros(telefone),
      if (cpf != null) 'cpf': _limparNumeros(cpf!),
      if (cnpj != null) 'cnpj': _limparNumeros(cnpj!),
      // Envia o ID apenas se for um UUID válido
      if (ultimoOrcamento != null && _isUuid(ultimoOrcamento!))
        'ultimo_orcamento_id': ultimoOrcamento,
    };
  }

  /// [uso]: Converte a resposta em JSON/Map vinda do Supabase em um objeto [Cliente] no app.
  factory Cliente.fromMap(Map<String, dynamic> map) {
    // Trata a busca da data vinda de tabelas relacionadas (JOIN)
    String? dataOuIdServico;
    final rawOrcamento = map['orcamentos'];

    if (rawOrcamento != null) {
      final Map<String, dynamic> orcamentoMap = rawOrcamento is List
          ? (rawOrcamento.isNotEmpty
                ? rawOrcamento.first as Map<String, dynamic>
                : {})
          : (rawOrcamento as Map<String, dynamic>? ?? {});

      dataOuIdServico =
          orcamentoMap['data_pega']?.toString() ??
          orcamentoMap['created_at']?.toString() ??
          orcamentoMap['data']?.toString();
    }

    // Fallback caso a consulta venha sem o JOIN
    dataOuIdServico ??=
        map['ultimo_orcamento_data']?.toString() ??
        map['ultimo_orcamento_id']?.toString();

    return Cliente(
      id: map['id']?.toString(),
      nome: (map['nome'] ?? '').toString(),
      rua: (map['rua'] ?? '').toString(),
      numero: (map['numero'] ?? '').toString(),
      complemento: map['complemento']?.toString(),
      bairro: (map['bairro'] ?? '').toString(),
      telefone: (map['telefone'] ?? '').toString(),
      cpf: map['cpf']?.toString(),
      cnpj: map['cnpj']?.toString(),
      clienteProblematico: map['cliente_problematico'] == true,
      observacao: map['observacao']?.toString(),
      criadoEm: map['criado_em'] != null
          ? DateTime.tryParse(map['criado_em'].toString())
          : null,
      ultimoOrcamento: dataOuIdServico,
    );
  }

  // ==================================================
  // MÉTODOS AUXILIARES
  // ==================================================

  /// [uso]: Remove todos os caracteres não numéricos de uma string (máscaras, pontos e traços).
  static String _limparNumeros(String valor) {
    return valor.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// [uso]: Valida se o formato do texto corresponde a um UUID do PostgreSQL.
  static bool _isUuid(String valor) {
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return uuidRegex.hasMatch(valor);
  }

  // ==================================================
  // CÓPIA E IGUALDADE
  // ==================================================

  /// [uso]: Clona o objeto [Cliente] permitindo alterar apenas os campos desejados.
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
    String? ultimoOrcamento,
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
      ultimoOrcamento: ultimoOrcamento ?? this.ultimoOrcamento,
    );
  }

  /// [uso]: Compara se dois objetos [Cliente] possuem os mesmos dados internos.
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
        other.ultimoOrcamento == ultimoOrcamento;
  }

  /// [uso]: Gera o identificador numérico (hash) do objeto para otimizar o uso em Lists e Sets.
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
      Object.hash(criadoEm, ultimoOrcamento),
    );
  }
}
