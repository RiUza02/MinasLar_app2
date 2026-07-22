// **[Propósito]** Entidade imutável que representa um cliente, centralizando seus dados cadastrais, histórico e regras de serialização com o Supabase.
// **[Como usar]** final cliente = Cliente.fromMap(jsonSupabase); / final payload = cliente.toMap();
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
  final String? ultimoOrcamento; // Data do serviço prestado ou ID associado.

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

  // **[Propósito]** Converte o objeto [Cliente] em um Map sanitizado para inserção ou atualização na API/Banco de Dados (Supabase).
  // **[Retorno]** Map<String, dynamic> -> Dados formatados (com remoção de máscaras e espaços em branco).
  // **[Como usar]** await supabase.from('clientes').insert(cliente.toMap());
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
      // Sanitização: persiste apenas a sequência numérica no banco de dados.
      'telefone': _limparNumeros(telefone),
      if (cpf != null) 'cpf': _limparNumeros(cpf!),
      if (cnpj != null) 'cnpj': _limparNumeros(cnpj!),
      // Associa a chave estrangeira do orçamento apenas se for um UUID válido.
      if (ultimoOrcamento != null && _isUuid(ultimoOrcamento!))
        'ultimo_orcamento_id': ultimoOrcamento,
    };
  }

  // **[Propósito]** Factory constructor que desserializa o Map vindo da consulta do Supabase em uma instância da classe [Cliente].
  // **[Parâmetros]** map (Map<String, dynamic>) -> Dados brutos do banco de dados (suporta consultas com ou sem JOIN em 'orcamentos').
  // **[Retorno]** Cliente -> Instância pronta para uso no aplicativo.
  // **[Como usar]** final cliente = Cliente.fromMap(response.data.first);
  factory Cliente.fromMap(Map<String, dynamic> map) {
    // Trata o parsing da data do último orçamento quando vinda de tabelas relacionadas (JOIN com 'orcamentos').
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

    // Estrutura de fallback para consultas simples sem JOIN relacional.
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

  // **[Propósito]** Remove todos os caracteres não numéricos (pontos, traços, parênteses e espaços) de uma string.
  static String _limparNumeros(String valor) {
    return valor.replaceAll(RegExp(r'[^0-9]'), '');
  }

  // **[Propósito]** Valida se o formato da string corresponde ao padrão UUID (v4/v1) utilizado pelo PostgreSQL.
  static bool _isUuid(String valor) {
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return uuidRegex.hasMatch(valor);
  }

  // ==================================================
  // CÓPIA E IGUALDADE
  // ==================================================

  // **[Propósito]** Cria uma nova instância de [Cliente] replicando os dados atuais e alterando apenas os parâmetros informados.
  // **[Como usar]** final clienteAtualizado = cliente.copyWith(telefone: '32988887777');
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

  // **[Propósito]** Avalia se duas instâncias de [Cliente] são estruturalmente idênticas comparando os valores de cada atributo.
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

  // **[Propósito]** Gera o código hash numérico do objeto baseado em seus campos para permitir comparações eficientes em coleções (Set/Map).
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
