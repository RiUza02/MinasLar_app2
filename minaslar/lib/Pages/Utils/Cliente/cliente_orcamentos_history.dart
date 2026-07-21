import '../../../../Core/Design/design_system.dart';
import '../../../../Core/Widgets/widgets.dart';
import '../../../Features/Repositorios/orcamento_repository.dart';
import '../../Orcamento/detalha_orcamento.dart';
import '../Orcamentos/orcamento_history_card.dart';

/// [uso] Exibe o histórico de orçamentos de um cliente,
/// destacando um orçamento específico quando informado.
class ClienteOrcamentosHistory extends StatefulWidget {
  /// Identificador do cliente.
  final String clienteId;

  /// Indica se o usuário possui permissões de administrador.
  final bool isAdmin;

  /// Id do orçamento que deve ser destacado na lista.
  final String? orcamentoIdDestaque;

  const ClienteOrcamentosHistory({
    super.key,
    required this.clienteId,
    required this.isAdmin,
    this.orcamentoIdDestaque,
  });

  @override
  State<ClienteOrcamentosHistory> createState() =>
      _ClienteOrcamentosHistoryState();
}

class _ClienteOrcamentosHistoryState extends State<ClienteOrcamentosHistory> {
  // Repositório responsável pela consulta dos orçamentos.
  final OrcamentoRepository _orcamentoRepository = OrcamentoRepository();

  // Future utilizada pelo FutureBuilder.
  late Future<List<Map<String, dynamic>>> _historicoFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  /// Carrega ou recarrega o histórico de orçamentos do cliente.
  void _loadHistory() {
    setState(() {
      _historicoFuture = _orcamentoRepository.buscarHistoricoPorCliente(
        widget.clienteId,
      );
    });
  }

  /// Navega para a tela de detalhes do orçamento e atualiza a lista se houver modificação.
  void _navegarParaDetalhes(Map<String, dynamic> orcamento) async {
    final foiModificado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhesOrcamento(
          orcamentoInicial: orcamento,
          isAdmin: widget.isAdmin,
        ),
      ),
    );

    // Se o orçamento foi alterado (editado/excluído), recarrega o histórico.
    if (foiModificado == true && mounted) {
      _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da seção.
        const AppSectionHeader(
          icon: AppIcons.historico,
          title: 'HISTÓRICO DE ORÇAMENTOS',
        ),

        // Aguarda o carregamento dos dados.
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _historicoFuture,
          builder: (context, snapshot) {
            // Exibe indicador de carregamento.
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Exibe mensagem em caso de erro.
            if (snapshot.hasError) {
              return const AppEmptyListIndicator(
                message: "Não foi possível carregar o histórico.",
                icon: AppIcons.orcamentos,
              );
            }

            final orcamentos = snapshot.data ?? [];

            // Exibe mensagem quando não há registros.
            if (orcamentos.isEmpty) {
              return const AppEmptyListIndicator(
                message: "Nenhum orçamento registrado para este cliente.",
                icon: AppIcons.orcamentos,
              );
            }

            // Lista os orçamentos encontrados.
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orcamentos.length,
              itemBuilder: (context, index) {
                final orcamento = orcamentos[index];

                return OrcamentoHistoryCard(
                  orcamento: orcamento,

                  // Primeiro item representa o orçamento mais recente.
                  isLast: index == 0,

                  // Destaca o orçamento informado.
                  isHighlight: orcamento['id'] == widget.orcamentoIdDestaque,

                  isAdmin: widget.isAdmin,
                  onActionCompleted: _loadHistory,
                  onTap: () => _navegarParaDetalhes(orcamento),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
