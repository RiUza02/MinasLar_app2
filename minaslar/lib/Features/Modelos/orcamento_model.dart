import 'package:flutter/material.dart';
import 'cliente_model.dart';

// **[Propósito]** Enumeração dos turnos operacionais de agendamento, evitando strings mágicas e garantindo integridade de dados.
enum Turno {
  manha('Manhã'),
  tarde('Tarde');

  const Turno(this.valor);
  final String valor;

  // **[Propósito]** Converte a string registrada no banco de dados para o Enum correspondente, adotando 'Tarde' como fallback padrão.
  // **[Parâmetros]** valorBanco (String?) -> Valor textual armazenado no banco.
  // **[Retorno]** Turno -> Instância tratada do Enum.
  static Turno fromString(String? valorBanco) {
    if (valorBanco == 'Manhã') return Turno.manha;
    return Turno.tarde;
  }
}

// **[Propósito]** Entidade imutável que representa um orçamento de serviço no sistema, otimizada para inserções e operações relacionais.
// **[Como usar]** final orcamento = Orcamento.fromMap(jsonSupabase); / final payload = orcamento.toMap();
class Orcamento {
  final String? id;
  final String clienteId;
  final Cliente? cliente;
  final String titulo;
  final String? descricao;
  final DateTime dataPega;
  final DateTime? dataEntrega;
  final double? valor;
  final Turno horarioDoDia;
  final bool entregue;
  final bool ehRetorno;
  final bool ehUrgente;
  final DateTime? atualizadoEm;

  const Orcamento({
    required this.clienteId,
    required this.titulo,
    required this.dataPega,
    this.cliente,
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

  // **[Propósito]** Converte o objeto [Orcamento] em um Map serializável para persistência no Supabase (ignora o objeto relacional `cliente`).
  // **[Retorno]** Map<String, dynamic> -> Estrutura de dados pronta para inserção/atualização SQL.
  // **[Como usar]** await supabase.from('orcamentos').upsert(orcamento.toMap());
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

  // **[Propósito]** Factory constructor que desserializa os dados do Supabase, incluindo mapeamento relacional do cliente via JOIN.
  // **[Parâmetros]** map (Map<String, dynamic>) -> Dados de orçamento retornados pelo banco de dados.
  // **[Retorno]** Orcamento -> Instância tratada contra erros de parsing e valores nulos.
  // **[Como usar]** final orcamento = Orcamento.fromMap(response.data.first);
  factory Orcamento.fromMap(Map<String, dynamic> map) {
    // Mapeamento dos dados do cliente vindos de joins relacionais da tabela 'clientes'.
    final clienteData = map['clientes'] ?? map['cliente'];

    return Orcamento(
      id: map['id']?.toString(),
      clienteId: map['cliente_id']?.toString() ?? '',
      cliente: clienteData != null && clienteData is Map<String, dynamic>
          ? Cliente.fromMap(clienteData)
          : null,
      titulo: map['titulo'] ?? 'Sem Título',
      descricao: map['descricao'],
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

  // **[Propósito]** Cria uma nova instância de [Orcamento] mantendo a imutabilidade e alterando apenas os atributos passados.
  // **[Como usar]** final orcamentoEntregue = orcamento.copyWith(entregue: true);
  Orcamento copyWith({
    String? id,
    String? clienteId,
    Cliente? cliente,
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
      cliente: cliente ?? this.cliente,
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

  // **[Propósito]** Indica se a entrega do serviço está em atraso em relação à data atual (desconsiderando horas).
  // **[Retorno]** bool -> Retorna `true` se não entregue e a data de entrega for anterior ao dia atual.
  bool get isAtrasado {
    if (entregue || dataEntrega == null) {
      return false;
    }
    final hoje = DateUtils.dateOnly(DateTime.now());
    final dataEntregaDateOnly = DateUtils.dateOnly(dataEntrega!);
    return dataEntregaDateOnly.isBefore(hoje);
  }

  // **[Propósito]** Compara se dois orçamentos são equivalentes avaliando o valor interno de todas as suas propriedades.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Orcamento &&
        other.id == id &&
        other.clienteId == clienteId &&
        other.cliente == cliente &&
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

  // **[Propósito]** Calcula o hash numérico do objeto agrupando seus campos para busca em alta performance.
  @override
  int get hashCode {
    return Object.hash(
      Object.hash(id, clienteId, cliente, titulo, descricao, dataPega),
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
