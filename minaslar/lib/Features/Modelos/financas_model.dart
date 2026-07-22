class Financas {
  final String? id;
  final int mes;
  final int ano;
  final double faturamento;
  final int orcamentosEntregues;
  final int orcamentosUrgentes;
  final int orcamentosRetorno;
  final int servicosManha;
  final int servicosTarde;
  final int totalServicos;
  final int novosClientes;
  final int clientesProblematicos;

  const Financas({
    this.id,
    required this.mes,
    required this.ano,
    this.faturamento = 0.0,
    this.orcamentosEntregues = 0,
    this.orcamentosUrgentes = 0,
    this.orcamentosRetorno = 0,
    this.servicosManha = 0,
    this.servicosTarde = 0,
    this.totalServicos = 0,
    this.novosClientes = 0,
    this.clientesProblematicos = 0,
  });

  factory Financas.fromMap(Map<String, dynamic> map) {
    return Financas(
      id: map['id']?.toString(),
      mes: map['mes'] ?? DateTime.now().month,
      ano: map['ano'] ?? DateTime.now().year,
      faturamento: (map['faturamento'] ?? 0.0).toDouble(),
      orcamentosEntregues: map['orcamentos_entregues'] ?? 0,
      orcamentosUrgentes: map['orcamentos_urgentes'] ?? 0,
      orcamentosRetorno: map['orcamentos_retorno'] ?? 0,
      servicosManha: map['servicos_manha'] ?? 0,
      servicosTarde: map['servicos_tarde'] ?? 0,
      totalServicos: map['total_servicos'] ?? 0,
      novosClientes: map['novos_clientes'] ?? 0,
      clientesProblematicos: map['clientes_problematicos'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'mes': mes,
      'ano': ano,
      'faturamento': faturamento,
      'orcamentos_entregues': orcamentosEntregues,
      'orcamentos_urgentes': orcamentosUrgentes,
      'orcamentos_retorno': orcamentosRetorno,
      'servicos_manha': servicosManha,
      'servicos_tarde': servicosTarde,
      'total_servicos': totalServicos,
      'novos_clientes': novosClientes,
      'clientes_problematicos': clientesProblematicos,
    };
  }
}
