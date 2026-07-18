import '../../../Core/Design/design_system.dart';
import '../../../Core/Errors/errors.dart';
import '../../../Core/Widgets/widgets.dart';
import '../../../Features/Repositorios/orcamento_repository.dart';
import '../../../core/Services/route_calculator.dart';

/// [uso] Tela principal de listagem dos agendamentos do dia, com interface adaptada ao perfil de acesso (Administrador ou Técnico).
class HomePage extends StatefulWidget {
  final bool isAdmin;

  const HomePage({super.key, required this.isAdmin});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  // Preserva o estado da tela e a posição do scroll ao alternar entre as abas da BottomNavigationBar.
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

  /// [uso] Executa a reconsulta ao banco de dados e sincroniza o estado visual com o indicador de carregamento do RefreshIndicator.
  Future<void> _atualizarLista() async {
    final novaConsulta = _orcamentoRepository.buscarOrcamentosDoDia();
    setState(() {
      _futureOrcamentos = novaConsulta;
    });
    // Aguarda a requisição finalizar para que a animação circular de refresh desapareça no momento certo.
    await novaConsulta;
  }

  /// [uso] Valida a existência de paradas na lista atual, formata os endereços e aciona o serviço nativo de mapas.
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
        final cliente = orc['clientes'] ?? {};
        return {
          'nome_cliente': cliente['nome'] ?? 'Cliente',
          'rua': cliente['rua'] ?? '',
          'numero': (cliente['numero'] ?? '').toString(),
          'bairro': cliente['bairro'] ?? '',
          'cidade': 'Juiz de Fora', // Cidade Padrão
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

  /// [uso] Inicia o fluxo de navegação para o formulário de cadastro de um novo atendimento.
  void _abrirNovoOrcamento() async {
    // TODO: Implementar a navegação para a tela de adicionar orçamento.
    AppFeedback.show(
      context,
      'Função de adicionar orçamento ainda não implementada.',
    );
  }

  /// [uso] Constrói o grupo vertical de botões flutuantes exclusivos para o perfil de administração.
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
    // O Scaffold interno isola os FloatingActionButtons desta tela da AppBar da estrutura principal.
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: widget.isAdmin ? _buildAdminFabs() : null,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureOrcamentos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: _themeColor));
          }

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

          if (orcamentos.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            color: _themeColor,
            backgroundColor: AppColors.cardBackground,
            onRefresh: _atualizarLista,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.spaceLarge,
                AppDimensions.spaceLarge,
                AppDimensions.spaceLarge,
                90, // Margem inferior de segurança para evitar sobreposição pelo FAB
              ),
              itemCount: orcamentos.length,
              // Garante que o gesto vertical de puxar funcione independentemente da quantidade de itens na tela.
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final orcamento = orcamentos[index];
                return OrcamentoCard(
                  orcamento: orcamento,
                  onCardTap: () {
                    // TODO: Implementar navegação para detalhes do orçamento e atualizar no retorno.
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

  /// [uso] Renderiza a interface de lista vazia dentro de um scroll ativo para permitir o gesto de Pull-to-Refresh em toda a tela.
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
