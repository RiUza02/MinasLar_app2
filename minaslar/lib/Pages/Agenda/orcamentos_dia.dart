import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../Core/Design/design_system.dart';
import '../../Core/Errors/errors.dart';
import '../../Core/Services/route_calculator.dart';
import '../../Core/Widgets/widgets.dart';
import '../../Features/Modelos/cliente_model.dart';
import '../Orcamento/cria_orcamento.dart';
import '../Utils/ListaOrcamento/seleciona_cliente.dart';

class OrcamentosDia extends StatefulWidget {
  final DateTime dataSelecionada;
  final bool isAdmin;

  const OrcamentosDia({
    super.key,
    required this.dataSelecionada,
    required this.isAdmin,
  });

  @override
  State<OrcamentosDia> createState() => _OrcamentosDiaState();
}

class _OrcamentosDiaState extends State<OrcamentosDia> {
  late Color _themeColor;
  late Future<List<Map<String, dynamic>>> _futureOrcamentos;
  List<Map<String, dynamic>> _listaDeOrcamentosDoDia = [];

  @override
  void initState() {
    super.initState();
    _themeColor = widget.isAdmin
        ? AppColors.primaryAlternative
        : AppColors.primary;
    _futureOrcamentos = _buscarOrcamentosDoDiaSelecionado();
  }

  /// Busca no Supabase os orçamentos do dia selecionado.
  Future<List<Map<String, dynamic>>> _buscarOrcamentosDoDiaSelecionado() async {
    final inicioDia = DateTime(
      widget.dataSelecionada.year,
      widget.dataSelecionada.month,
      widget.dataSelecionada.day,
    );
    final fimDia = DateTime(
      widget.dataSelecionada.year,
      widget.dataSelecionada.month,
      widget.dataSelecionada.day,
      23,
      59,
      59,
    );

    final response = await Supabase.instance.client
        .from('orcamentos')
        .select('*, clientes!orcamentos_cliente_id_fkey(*)')
        .gte('data_pega', inicioDia.toIso8601String())
        .lte('data_pega', fimDia.toIso8601String());

    final orcamentos = List<Map<String, dynamic>>.from(response);
    orcamentos.sort(_compararHorarios);

    return orcamentos;
  }

  int _compararHorarios(dynamic a, dynamic b) {
    final horarioA = (a['horario_do_dia'] ?? '').toString().toLowerCase();
    final horarioB = (b['horario_do_dia'] ?? '').toString().toLowerCase();

    if (horarioA == 'manhã' && horarioB != 'manhã') return -1;
    if (horarioB == 'manhã' && horarioA != 'manhã') return 1;
    return 0;
  }

  /// Recarrega a lista de agendamentos.
  Future<void> _atualizarLista() async {
    final novaConsulta = _buscarOrcamentosDoDiaSelecionado();
    setState(() {
      _futureOrcamentos = novaConsulta;
    });
    await novaConsulta;
  }

  /// Extrai os endereços e abre o mapa com a rota otimizada.
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

  void _navegarParaCriarOrcamento() async {
    // 1. Navega para a tela de seleção de cliente
    final Cliente? clienteEscolhido = await Navigator.push<Cliente>(
      context,
      MaterialPageRoute(builder: (context) => const SelecionaClientePage()),
    );

    // 2. Se um cliente foi escolhido, navega para a tela de criação de orçamento
    if (clienteEscolhido != null && mounted) {
      final bool? orcamentoAdicionado = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => AdicionarOrcamento(
            cliente: clienteEscolhido,
            dataSelecionada: widget.dataSelecionada, // Passa a data do dia
          ),
        ),
      );

      // 3. Se o orçamento foi criado com sucesso, atualiza a lista na tela
      if (orcamentoAdicionado == true) {
        _atualizarLista();
      }
    }
  }

  /// Constrói o botão flutuante (FAB) de rota para perfil administrador.
  Widget _buildAdminFab() {
    return FloatingActionButton(
      heroTag: "btnRotaDia",
      onPressed: _gerarRota,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textPrimary,
      child: const Icon(Icons.map_outlined),
    );
  }

  /// Exibe a mensagem de lista vazia com pull-to-refresh.
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
                message: 'Nenhum agendamento para este dia.',
                icon: Icons.event_busy_outlined,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dia ${DateFormat("dd/MM/yyyy").format(widget.dataSelecionada)}',
        ),
        centerTitle: true,
        backgroundColor: widget.isAdmin
            ? AppColors.primaryAlternative
            : AppColors.primary,
      ),
      floatingActionButton: widget.isAdmin
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: "btnNovoOrcamentoDia",
                  onPressed: _navegarParaCriarOrcamento,
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.textPrimary,
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: AppDimensions.spaceMedium),
                _buildAdminFab(),
              ],
            )
          : null,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureOrcamentos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _listaDeOrcamentosDoDia.isEmpty) {
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
                90,
              ),
              itemCount: orcamentos.length,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final orcamento = orcamentos[index];
                return OrcamentoCard(
                  orcamento: orcamento,
                  isAdmin: widget.isAdmin,
                  onRefresh: _atualizarLista,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
