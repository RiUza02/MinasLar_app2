import '../../../Core/Design/design_system.dart';
import '../../../Core/Errors/errors.dart';
import '../../../Core/Services/route_calculator.dart';
import '../../../Core/Widgets/widgets.dart';
import '../../../Features/Repositorios/orcamento_repository.dart';

/// [uso]: Tela principal de agendamentos do dia adaptada ao perfil do usuário (Admin ou Técnico).
class OverView extends StatefulWidget {
  final bool isAdmin;

  const OverView({super.key, required this.isAdmin});

  @override
  State<OverView> createState() => _OverViewState();
}

class _OverViewState extends State<OverView>
    with AutomaticKeepAliveClientMixin {
  // Preserva o estado da aba ao alternar na BottomNavigationBar
  @override
  bool get wantKeepAlive => true;

  late Color _themeColor;
  final _orcamentoRepository = OrcamentoRepository();
  late Future<List<Map<String, dynamic>>> _futureOrcamentos;
  List<Map<String, dynamic>> _listaDeOrcamentosDoDia = [];

  @override
  void initState() {
    super.initState();
    _themeColor = widget.isAdmin
        ? AppColors.primaryAlternative
        : AppColors.primary;
    _futureOrcamentos = _orcamentoRepository.buscarOrcamentosDoDia();
  }

  /// [uso]: Recarrega a lista de agendamentos e atualiza o estado para a animação do Pull-to-Refresh.
  Future<void> _atualizarLista() async {
    final novaConsulta = _orcamentoRepository.buscarOrcamentosDoDia();
    setState(() {
      _futureOrcamentos = novaConsulta;
    });
    await novaConsulta;
  }

  /// [uso]: Extrai os endereços da lista de agendamentos e abre o aplicativo de mapas com a rota otimizada.
  Future<void> _gerarRota() async {
    if (_listaDeOrcamentosDoDia.isEmpty) {
      AppFeedback.show(
        context,
        "Não há atendimentos na lista para gerar rota.",
      );
      return;
    }

    AppFeedback.show(context, "Calculando a melhor rota...");

    try {
      final routeCalculator = RouteCalculator();
      final List<Map<String, dynamic>> stopsData = _listaDeOrcamentosDoDia.map((
        orc,
      ) {
        final cliente = (orc['clientes'] as Map<String, dynamic>?) ?? {};
        return {
          'nome_cliente': cliente['nome'] ?? 'Cliente',
          'rua': cliente['rua'] ?? '',
          'numero': (cliente['numero'] ?? '').toString(),
          'bairro': cliente['bairro'] ?? '',
          'cidade': 'Juiz de Fora',
        };
      }).toList();

      await routeCalculator.optimizeAndOpenRoute(stopsData);
    } catch (e) {
      if (mounted) {
        AppFeedback.show(
          context,
          ErrorHandler.mapearErro(e),
          type: FeedbackType.error,
        );
      }
    }
  }

  /// [uso]: Abre a tela de criação de um novo orçamento.
  void _abrirNovoOrcamento() async {
    AppFeedback.show(
      context,
      'Função de adicionar orçamento ainda não implementada.',
    );
  }

  /// [uso]: Constrói os botões flutuantes (FABs) de rota e novo orçamento para perfil administrador.
  Widget _buildAdminFabs() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: "btnRota",
          onPressed: _gerarRota,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textPrimary,
          child: const Icon(Icons.map_outlined),
        ),
        const SizedBox(height: AppDimensions.spaceLarge),
        FloatingActionButton(
          heroTag: "btnAdd",
          onPressed: _abrirNovoOrcamento,
          backgroundColor: _themeColor,
          foregroundColor: AppColors.textPrimary,
          child: const Icon(AppIcons.add),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: widget.isAdmin ? _buildAdminFabs() : null,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureOrcamentos,
        builder: (context, snapshot) {
          // Exibe loading central apenas se a lista estiver completamente vazia
          if (snapshot.connectionState == ConnectionState.waiting &&
              _listaDeOrcamentosDoDia.isEmpty) {
            return Center(child: CircularProgressIndicator(color: _themeColor));
          }

          // Exibe tela de erro amigável
          if (snapshot.hasError) {
            return AppErrorView(
              message: ErrorHandler.mapearErro(snapshot.error!),
              buttonText: 'Tentar Novamente',
              onTryAgain: _atualizarLista,
              icon: snapshot.error is NetworkException
                  ? Icons.wifi_off_outlined
                  : AppIcons.erro,
            );
          }

          final orcamentos = snapshot.data ?? [];
          _listaDeOrcamentosDoDia = orcamentos;

          // Exibe indicador de lista vazia
          if (orcamentos.isEmpty) {
            return _buildEmptyState();
          }

          // Renderiza a lista com Pull-to-Refresh
          return RefreshIndicator(
            color: _themeColor,
            backgroundColor: AppColors.cardBackground,
            onRefresh: _atualizarLista,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.spaceLarge,
                AppDimensions.spaceLarge,
                AppDimensions.spaceLarge,
                90,
              ),
              itemCount: orcamentos.length,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final orcamento = orcamentos[index];
                return OrcamentoCard(
                  orcamento: orcamento,
                  onCardTap: () {
                    AppFeedback.show(
                      context,
                      'Função de detalhes ainda não implementada.',
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// [uso]: Exibe a mensagem de lista vazia mantendo o gesto de Pull-to-Refresh habilitado.
  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _atualizarLista,
      color: _themeColor,
      backgroundColor: AppColors.cardBackground,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              height: constraints.maxHeight,
              alignment: Alignment.center,
              child: const AppEmptyListIndicator(
                message: 'Nenhum agendamento para hoje.',
                icon: Icons.event_available_outlined,
              ),
            ),
          );
        },
      ),
    );
  }
}
