// **[Propósito]** Entidade imutável para gestão e relatórios do fechamento financeiro e métricas consolidadas mensais.
// **[Como usar]** final financas = Financas.fromMap(jsonSupabase); / final payload = financas.toMap();
class Financas {
  final String? id;
  final int mes;
  final int ano;
  final double faturamento;
  final int orcamentosDia;
  final int orcamentosTarde;
  final int totalOrcamentos;
  final int novosClientes;
  final int retornosGarantia;

  const Financas({
    this.id,
    required this.mes,
    required this.ano,
    this.faturamento = 0.0,
    this.orcamentosDia = 0,
    this.orcamentosTarde = 0,
    this.totalOrcamentos = 0,
    this.novosClientes = 0,
    this.retornosGarantia = 0,
  });

  // ==================================================
  // MÉTODOS DE SERIALIZAÇÃO (SUPABASE)
  // ==================================================

  // **[Propósito]** Converte o objeto [Financas] em um Map para inclusão ou atualização de relatórios no banco de dados.
  // **[Retorno]** Map<String, dynamic> -> Estrutura pronta para persistência na tabela de finanças.
  // **[Como usar]** await supabase.from('financas').insert(financas.toMap());
  Map<String, dynamic> toMap() {
    return {
      'mes': mes,
      'ano': ano,
      'faturamento': faturamento,
      'orcamentos_dia': orcamentosDia,
      'orcamentos_tarde': orcamentosTarde,
      'total_orcamentos': totalOrcamentos,
      'novos_clientes': novosClientes,
      'retornos_garantia': retornosGarantia,
    };
  }

  // **[Propósito]** Factory constructor para desserializar os dados do fechamento mensal vindos do Supabase.
  // **[Parâmetros]** map (Map<String, dynamic>) -> Dados de finanças retornados do banco.
  // **[Retorno]** Financas -> Instância com tratamento contra valores nulos e parsing seguro de números.
  // **[Como usar]** final financaMensal = Financas.fromMap(response.data.first);
  factory Financas.fromMap(Map<String, dynamic> map) {
    return Financas(
      id: map['id']?.toString(),
      mes: map['mes'] ?? DateTime.now().month,
      ano: map['ano'] ?? DateTime.now().year,
      faturamento: (map['faturamento'] ?? 0.0).toDouble(),
      orcamentosDia: map['orcamentos_dia'] ?? 0,
      orcamentosTarde: map['orcamentos_tarde'] ?? 0,
      totalOrcamentos: map['total_orcamentos'] ?? 0,
      novosClientes: map['novos_clientes'] ?? 0,
      retornosGarantia: map['retornos_garantia'] ?? 0,
    );
  }

  // ==================================================
  // MÉTODOS DE CÓPIA E COMPARAÇÃO
  // ==================================================

  // **[Propósito]** Gera uma cópia do registro de [Financas], atualizando pontualmente os atributos passados.
  // **[Como usar]** final atualizado = financas.copyWith(faturamento: 15000.0);
  Financas copyWith({
    String? id,
    int? mes,
    int? ano,
    double? faturamento,
    int? orcamentosDia,
    int? orcamentosTarde,
    int? totalOrcamentos,
    int? novosClientes,
    int? retornosGarantia,
  }) {
    return Financas(
      id: id ?? this.id,
      mes: mes ?? this.mes,
      ano: ano ?? this.ano,
      faturamento: faturamento ?? this.faturamento,
      orcamentosDia: orcamentosDia ?? this.orcamentosDia,
      orcamentosTarde: orcamentosTarde ?? this.orcamentosTarde,
      totalOrcamentos: totalOrcamentos ?? this.totalOrcamentos,
      novosClientes: novosClientes ?? this.novosClientes,
      retornosGarantia: retornosGarantia ?? this.retornosGarantia,
    );
  }

  // **[Propósito]** Compara se dois registros de [Financas] possuem valores equivalentes em todas as suas métricas.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Financas &&
        other.id == id &&
        other.mes == mes &&
        other.ano == ano &&
        other.faturamento == faturamento &&
        other.orcamentosDia == orcamentosDia &&
        other.orcamentosTarde == orcamentosTarde &&
        other.totalOrcamentos == totalOrcamentos &&
        other.novosClientes == novosClientes &&
        other.retornosGarantia == retornosGarantia;
  }

  // **[Propósito]** Gera o hash numérico do objeto agrupando seus atributos para garantir integridade em coleções (Set/Map).
  @override
  int get hashCode {
    return Object.hash(
      id,
      mes,
      ano,
      faturamento,
      orcamentosDia,
      orcamentosTarde,
      totalOrcamentos,
      novosClientes,
      retornosGarantia,
    );
  }
}
