import 'package:intl/date_symbol_data_local.dart';
import '../../../Core/Design/design_system.dart';
import '../../../Core/Errors/errors.dart';
import '../../../Core/Widgets/widgets.dart';
import '../../Features/Modelos/financas_model.dart';
import '../../../Features/Repositorios/financas_repository.dart';
import '../Utils/Dashboard/clientes_section.dart';
import '../Utils/Dashboard/comparativo_section.dart';
import '../Utils/Dashboard/faturamento_section.dart';
import '../Utils/Dashboard/operacional_section.dart';
import '../Utils/Dashboard/orcamentos_section.dart';

// **[Propósito]** Tela de painel gerencial (Dashboard) que exibe métricas financeiras, operacionais e de clientes.
// **[Como usar]** Empregada como uma das abas principais para usuários com perfil de administrador, permitindo visualização de gráficos e sincronização de dados estatísticos.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // **[Estado Local]** Controle de carregamento, sincronização e armazenamento das métricas mensais e histórico de 6 meses.
  bool _isLoading = true;
  bool _isSyncing = false;
  String? _error;

  // Repositório
  final ProcessaOrcamentos _repo = ProcessaOrcamentos();

  // Métricas do Mês Atual
  double _faturamentoMesAtual = 0;
  int _orcamentosEntregues = 0;
  int _novosClientes = 0;
  int _orcamentosRetorno = 0;
  int _orcamentosUrgentes = 0;
  int _servicosManha = 0;
  int _servicosTarde = 0;
  int _clientesProblematicos = 0;

  // Dados dos Gráficos (Histórico)
  List<Map<String, dynamic>> _faturamento6Meses = [];
  List<Map<String, dynamic>> _stats6Meses = [];
  Map<String, int> _servicosPorTurno = {'Manhã': 0, 'Tarde': 0};

  // Cores
  final Color _corOrcamentos = AppColors.primary;
  final Color _corClientes = AppColors.success;
  final Color _corRetornos = AppColors.warning;

  // **[Comportamento: Cálculos em Tempo Real]** Getters que derivam valores agregados e percentuais a partir dos dados brutos carregados no estado.
  double get _faturamentoTotal6Meses {
    return _faturamento6Meses.fold(
      0.0,
      (sum, item) => sum + ((item['value'] as num?)?.toDouble() ?? 0.0),
    );
  }

  double get _taxaRetornoPercentual {
    if (_orcamentosEntregues == 0) return 0.0;
    return (_orcamentosRetorno / _orcamentosEntregues) * 100;
  }

  double get _taxaProblematicosVsNovosPercentual {
    if (_novosClientes == 0) return 0.0;
    return (_clientesProblematicos / _novosClientes) * 100;
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null).then((_) {
      _carregarDados();
    });
  }

  // **[Ação: Carregar Dados]** Busca as métricas e dados dos gráficos no repositório financeiro, atualizando os estados de tela e tratando erros.
  Future<void> _carregarDados() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dados = await _repo.buscarDadosDashboard();
      if (mounted) {
        final Financas? financaAtual = dados['financaMesAtual'] as Financas?;

        setState(() {
          _faturamentoMesAtual = (dados['faturamentoMesAtual'] ?? 0.0)
              .toDouble();
          _faturamento6Meses = List<Map<String, dynamic>>.from(
            dados['graficoFaturamento'] ?? [],
          );
          _servicosPorTurno = Map<String, int>.from(
            dados['turnos'] ?? {'Manhã': 0, 'Tarde': 0},
          );
          _stats6Meses = List<Map<String, dynamic>>.from(
            dados['graficoBarras'] ?? [],
          );

          if (financaAtual != null) {
            _orcamentosEntregues = financaAtual.orcamentosEntregues;
            _novosClientes = financaAtual.novosClientes;
            _orcamentosRetorno = financaAtual.orcamentosRetorno;
            _orcamentosUrgentes = financaAtual.orcamentosUrgentes;
            _servicosManha = financaAtual.servicosManha;
            _servicosTarde = financaAtual.servicosTarde;
            _clientesProblematicos = financaAtual.clientesProblematicos;
          } else {
            _servicosManha = _servicosPorTurno['Manhã'] ?? 0;
            _servicosTarde = _servicosPorTurno['Tarde'] ?? 0;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        _error = ErrorHandler.mapearErro(e);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // **[Ação: Sincronização]** Força a atualização e processamento dos dados financeiros no backend/banco local, provendo feedback visual do resultado.
  Future<void> _sincronizarDashboard() async {
    if (!mounted || _isSyncing) return;
    setState(() => _isSyncing = true);

    try {
      final mesesAtualizados = await _repo.sincronizarFinancas();
      if (mounted) {
        if (mesesAtualizados > 0) {
          AppFeedback.show(
            context,
            '$mesesAtualizados ${mesesAtualizados == 1 ? 'mês foi atualizado' : 'meses foram atualizados'}.',
            type: FeedbackType.success,
          );
          await _carregarDados();
        } else {
          AppFeedback.show(context, 'Seus dados já estão sincronizados!');
        }
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.show(
          context,
          ErrorHandler.mapearErro(e),
          type: FeedbackType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  // **[Ação: Interação do Usuário]** Fornece um alerta informativo ao clicar no indicador de clientes problemáticos.
  void _abrirListaClientesProblematicos() {
    AppFeedback.show(
      context,
      'Redirecionando para a lista de clientes problemáticos...',
      type: FeedbackType.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        heroTag: 'btnSyncDashboard',
        onPressed: _sincronizarDashboard,
        backgroundColor: AppColors.primaryAlternative,
        foregroundColor: AppColors.textPrimary,
        child: _isSyncing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.textPrimary,
                  strokeWidth: 2.5,
                ),
              )
            : const Icon(AppIcons.atualizar),
      ),
      body: _buildBody(),
    );
  }

  // **[Subcomponente: Corpo Principal]** Constrói a interface do dashboard dividida em seções modulares, tratando também os estados de carregamento (loading) e erro.
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryAlternative),
      );
    }

    if (_error != null) {
      return AppErrorView(
        message: _error!,
        buttonText: 'Tentar Novamente',
        onTryAgain: _carregarDados,
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarDados,
      color: AppColors.primaryAlternative,
      backgroundColor: AppColors.cardBackground,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppDimensions.spaceLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Painel de Visão Geral Finanças (Card Principal 6 Meses + Linhas)
            FaturamentoSection(
              faturamentoTotal6Meses: _faturamentoTotal6Meses,
              faturamentoMesAtual: _faturamentoMesAtual,
              faturamento6MesesData: _faturamento6Meses,
            ),
            const SizedBox(height: AppDimensions.spaceXLarge),

            // 2. Métricas Mensais de Orçamentos (Cards / KPIs)
            OrcamentosSection(
              orcamentosEntregues: _orcamentosEntregues,
              orcamentosRetorno: _orcamentosRetorno,
              taxaRetornoPercentual: _taxaRetornoPercentual,
              orcamentosUrgentes: _orcamentosUrgentes,
            ),
            const SizedBox(height: AppDimensions.spaceXLarge),

            // 3. Métricas de Clientes (Cards Informativos)
            ClientesSection(
              novosClientes: _novosClientes,
              clientesProblematicos: _clientesProblematicos,
              taxaProblematicosVsNovosPercentual:
                  _taxaProblematicosVsNovosPercentual,
              onProblematicosTap: _abrirListaClientesProblematicos,
            ),
            const SizedBox(height: AppDimensions.spaceXLarge),

            // 4. Operacional e Atendimentos (Turnos Manhã vs. Tarde)
            OperacionalSection(
              servicosManha: _servicosManha,
              servicosTarde: _servicosTarde,
            ),
            const SizedBox(height: AppDimensions.spaceXLarge),

            // 5. Visão Geral Comparativa (Gráfico de Barras)
            ComparativoSection(
              stats6Meses: _stats6Meses,
              corOrcamentos: _corOrcamentos,
              corClientes: _corClientes,
              corRetornos: _corRetornos,
            ),
            const SizedBox(height: AppDimensions.spaceXXXLarge),
          ],
        ),
      ),
    );
  }
}
