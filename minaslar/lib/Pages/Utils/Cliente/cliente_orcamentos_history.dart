import '../../../../Core/Design/design_system.dart';
import '../../../../Core/Widgets/widgets.dart';
import '../../../Features/Repositorios/orcamento_repository.dart';
import '../../Orcamento/detalha_orcamento.dart';
import '../Orcamentos/orcamento_history_card.dart';

// **[Propósito]** Componente visual e de estado (StatefulWidget) responsável por buscar e exibir a lista com o histórico de orçamentos de um cliente específico. Trata os estados de carregamento, erro e lista vazia, além de permitir o destaque de um orçamento e a navegação para seus detalhes.
// **[Como usar]** ClienteOrcamentosHistory(clienteId: 'id_do_cliente', isAdmin: true, orcamentoIdDestaque: 'id_opcional_para_destaque');
class ClienteOrcamentosHistory extends StatefulWidget {
  final String clienteId;
  final bool isAdmin;
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
  final OrcamentoRepository _orcamentoRepository = OrcamentoRepository();
  late Future<List<Map<String, dynamic>>> _historicoFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    setState(() {
      _historicoFuture = _orcamentoRepository.buscarHistoricoPorCliente(
        widget.clienteId,
      );
    });
  }

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

    if (foiModificado == true && mounted) {
      _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(
          icon: AppIcons.historico,
          title: 'HISTÓRICO DE ORÇAMENTOS',
        ),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _historicoFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const AppEmptyListIndicator(
                message: "Não foi possível carregar o histórico.",
                icon: AppIcons.orcamentos,
              );
            }

            final orcamentos = snapshot.data ?? [];

            if (orcamentos.isEmpty) {
              return const AppEmptyListIndicator(
                message: "Nenhum orçamento registrado para este cliente.",
                icon: AppIcons.orcamentos,
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orcamentos.length,
              itemBuilder: (context, index) {
                final orcamento = orcamentos[index];
                final orcamentoParaExibir = Map<String, dynamic>.from(
                  orcamento,
                );

                // Remove o valor do orçamento se o usuário não for admin
                if (!widget.isAdmin) {
                  orcamentoParaExibir.remove('valor');
                }

                return OrcamentoHistoryCard(
                  orcamento: orcamentoParaExibir,
                  isLast: index == 0,
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
