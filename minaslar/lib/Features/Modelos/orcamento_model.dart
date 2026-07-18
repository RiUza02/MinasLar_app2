/// Enum para representar os turnos de agendamento,
/// evitando o uso de "magic strings".
enum Turno {
  manha('Manhã'),
  tarde('Tarde');

  const Turno(this.valor);
  final String valor;

  /// Converte a string do banco de dados para o Enum otimizado de forma segura.
  /// Modificado para adotar [Turno.tarde] como padrão caso seja nulo ou inválido.
  static Turno fromString(String? valorBanco) {
    if (valorBanco == 'Manhã') return Turno.manha;
    return Turno.tarde; // Padrão agora é Tarde
  }
}

/// Modelo que representa um orçamento no sistema.
/// Otimizado para alto volume de inserção e atualizações pontuais (upsert).
class Orcamento {
  /// ID do registro no Supabase (UUID). Nulo antes da primeira inserção no banco.
  final String? id;

  /// ID do cliente relacionado ao orçamento (chave estrangeira indexada).
  final String clienteId;

  /// Título do serviço (Ex: "Formatação PC", "Troca de Tela").
  final String titulo;

  /// Descrição detalhada do serviço realizado.
  final String? descricao;

  /// Data em que o serviço foi iniciado ou agendado.
  final DateTime dataPega;

  /// Data prevista ou efetiva de entrega do serviço.
  final DateTime? dataEntrega;

  /// Valor financeiro do orçamento.
  final double? valor;

  /// Turno do agendamento ('Manhã' ou 'Tarde'). Padrão: [Turno.tarde].
  final Turno horarioDoDia;

  /// Indica se o serviço foi concluído/entregue.
  final bool entregue;

  /// Indica se o serviço é um retorno de garantia/revisão.
  final bool ehRetorno;

  /// Indica se é urgente, para priorização visual e na query SQL.
  final bool ehUrgente;

  /// Carimbo de tempo para auditoria e controle de última modificação.
  final DateTime? atualizadoEm;

  /// Construtor imutável com const para performance de memória no Flutter.
  /// [horarioDoDia] deixou de ser required e agora assume [Turno.tarde] por padrão.
  const Orcamento({
    required this.clienteId,
    required this.titulo,
    required this.dataPega,
    this.horarioDoDia = Turno.tarde,
    this.id,
    this.descricao,
    this.dataEntrega,
    this.valor,
    this.entregue = false,
    this.ehRetorno = false,
    this.ehUrgente = false,
    this.atualizadoEm,
  });

  // ==================================================
  // MÉTODOS DE SERIALIZAÇÃO E OTIMIZAÇÃO (SUPABASE)
  // ==================================================
  /// Converte o objeto Dart em um [Map] compatível com o Supabase.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'cliente_id': clienteId,
      'titulo': titulo.trim(),
      'descricao': descricao?.trim(),
      'data_pega': dataPega.toUtc().toIso8601String(),
      'data_entrega': dataEntrega?.toUtc().toIso8601String(),
      'valor': valor,
      'horario_do_dia': horarioDoDia.valor,
      'entregue': entregue,
      'eh_retorno': ehRetorno,
      'eh_urgente': ehUrgente,
      'atualizado_em': DateTime.now().toUtc().toIso8601String(),
    };
  }

  /// Cria um objeto [Orcamento] a partir de um [Map] (JSON) do Supabase.
  factory Orcamento.fromMap(Map<String, dynamic> map) {
    return Orcamento(
      id: map['id']?.toString(),
      clienteId: map['cliente_id']?.toString() ?? '',
      titulo: map['titulo'] ?? 'Sem Título',
      descricao: map['descricao'],

      // Proteção contra falhas de conversão em registros antigos
      dataPega: map['data_pega'] != null
          ? DateTime.tryParse(map['data_pega'].toString()) ?? DateTime.now()
          : DateTime.now(),

      dataEntrega: map['data_entrega'] != null
          ? DateTime.tryParse(map['data_entrega'].toString())
          : null,

      valor: map['valor'] != null ? (map['valor'] as num).toDouble() : null,
      horarioDoDia: Turno.fromString(map['horario_do_dia']),
      entregue: map['entregue'] ?? false,
      ehRetorno: map['eh_retorno'] ?? false,
      ehUrgente: map['eh_urgente'] ?? false,
      atualizadoEm: map['atualizado_em'] != null
          ? DateTime.tryParse(map['atualizado_em'].toString())
          : null,
    );
  }

  // ==================================================
  // MÉTODOS DE GERÊNCIA DE ESTADO E COMPARAÇÃO
  // ==================================================
  /// Cria uma cópia do orçamento alterando apenas os campos fornecidos.
  /// Fundamental para gerência de estado sem mutabilidade direta.
  Orcamento copyWith({
    String? id,
    String? clienteId,
    String? titulo,
    String? descricao,
    DateTime? dataPega,
    DateTime? dataEntrega,
    double? valor,
    Turno? horarioDoDia,
    bool? entregue,
    bool? ehRetorno,
    bool? ehUrgente,
    DateTime? atualizadoEm,
  }) {
    return Orcamento(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      dataPega: dataPega ?? this.dataPega,
      dataEntrega: dataEntrega ?? this.dataEntrega,
      valor: valor ?? this.valor,
      horarioDoDia: horarioDoDia ?? this.horarioDoDia,
      entregue: entregue ?? this.entregue,
      ehRetorno: ehRetorno ?? this.ehRetorno,
      ehUrgente: ehUrgente ?? this.ehUrgente,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Orcamento &&
        other.id == id &&
        other.clienteId == clienteId &&
        other.clienteId == clienteId &&
        other.titulo == titulo &&
        other.descricao == descricao &&
        other.dataPega == dataPega &&
        other.dataEntrega == dataEntrega &&
        other.valor == valor &&
        other.horarioDoDia == horarioDoDia &&
        other.entregue == entregue &&
        other.ehRetorno == ehRetorno &&
        other.ehUrgente == ehUrgente &&
        other.atualizadoEm == atualizadoEm;
  }

  @override
  int get hashCode {
    // Agrupamento seguro em Object.hash para evitar o limite antigo de argumentos
    return Object.hash(
      Object.hash(id, clienteId, clienteId, titulo, descricao, dataPega),
      Object.hash(
        dataEntrega,
        valor,
        horarioDoDia,
        entregue,
        ehRetorno,
        ehUrgente,
      ),
      atualizadoEm,
    );
  }
}
