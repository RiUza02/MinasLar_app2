import 'package:intl/intl.dart';

import '../../Core/Design/design_system.dart';
import '../../Core/Widgets/widgets.dart';
import '../../Features/Modelos/cliente_model.dart';
import '../../Features/Modelos/orcamento_model.dart';
import '../../Features/Repositorios/orcamento_repository.dart';
import '../Cliente/detalha_cliente.dart';
import '../Utils/ListaOrcamento/detalhes_orcamento_controller.dart';
import '../Utils/ListaOrcamento/widgets.dart';
import 'edita_orcamento.dart';

// ==================================================
// TELA DE DETALHES DO ORÇAMENTO (UNIFICADA)
// ==================================================
class DetalhesOrcamento extends StatefulWidget {
  final Map<String, dynamic> orcamentoInicial;
  final bool isAdmin;

  const DetalhesOrcamento({
    super.key,
    required this.orcamentoInicial,
    required this.isAdmin, // Define se é visão de Admin ou Usuário
  });

  @override
  State<DetalhesOrcamento> createState() => _DetalhesOrcamentoState();
}

class _DetalhesOrcamentoState extends State<DetalhesOrcamento> {
  // ==================================================
  // ESTADO E VARIÁVEIS
  // ==================================================
  late final DetalhesOrcamentoController _controller;

  // Cores dinâmicas
  late Color corPrincipal;
  late Color corSecundaria;
  @override
  void initState() {
    super.initState();
    // Configura cores baseadas no tipo de usuário
    if (widget.isAdmin) {
      corPrincipal = AppColors.primaryAlternative;
      corSecundaria = AppColors.primary;
    } else {
      corPrincipal = AppColors.primary;
      corSecundaria = AppColors.borderFocused;
    }

    _controller = DetalhesOrcamentoController(
      repository: OrcamentoRepository(),
      orcamentoInicial: Orcamento.fromMap(widget.orcamentoInicial),
    );

    _controller.carregarDetalhes();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ==================================================
  // LÓGICA DE DADOS
  // ==================================================

  Future<void> _alterarStatusEntrega() async {
    final resultado = await _controller.alterarStatusEntrega();

    if (!mounted) return;

    if (resultado == null) {
      AppFeedback.show(
        context,
        'Status alterado com sucesso!',
        type: FeedbackType.success,
      );
    } else {
      AppFeedback.show(
        context,
        'Erro ao alterar status: $resultado',
        type: FeedbackType.error,
      );
    }
  }

  Future<void> _excluirOrcamento() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text("Excluir Orçamento", style: AppTextStyles.titleMedium),
        content: Text(
          "Tem certeza? Esta ação não pode ser desfeita.",
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCELAR"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("EXCLUIR", style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final resultado = await _controller.excluirOrcamento();
      if (mounted) {
        if (resultado == null) {
          AppFeedback.show(
            context,
            'Orçamento excluído!',
            type: FeedbackType.success,
          );
          Navigator.pop(context, true);
        } else {
          AppFeedback.show(
            context,
            'Erro ao excluir: $resultado',
            type: FeedbackType.error,
          );
        }
      }
    }
  }

  void _navegarEditar() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditarOrcamento(orcamento: _controller.orcamento.toMap()),
      ),
    );

    if (resultado == true) {
      _controller.carregarDetalhes();
    }
  }

  void _navegarDetalhesCliente() {
    final Cliente? cliente = _controller.orcamento.cliente;

    if (cliente != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              DetalhesClientePage(cliente: cliente, isAdmin: widget.isAdmin),
        ),
      ).then((_) => _controller.carregarDetalhes());
    } else {
      AppFeedback.show(
        context,
        "Dados do cliente incompletos.",
        type: FeedbackType.info,
      );
    }
  }

  // ==================================================
  // INTERFACE (BUILD)
  // ==================================================
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final orcamento = _controller.orcamento;
        final bool isConcluido = orcamento.entregue;
        final String horario = orcamento.horarioDoDia.valor;
        final bool isTarde = horario.toLowerCase() == 'tarde';
        final bool isAtrasado = orcamento.isAtrasado;

        final IconData iconHorario = isTarde
            ? AppIcons.tarde
            : AppIcons.manha; // Lógica de UI
        final Color corHorario = isTarde
            ? AppColors.afternoonShift
            : AppColors.morningShift;

        final String textoValor = orcamento.valor != null
            ? NumberFormat.currency(
                locale: 'pt_BR',
                symbol: 'R\$',
              ).format(orcamento.valor)
            : 'A Combinar';

        final Color corValor = orcamento.valor != null
            ? AppColors.adminColor
            : AppColors.textDisabled;

        Color corBordaPrincipal;
        if (isConcluido) {
          corBordaPrincipal = AppColors.primary; // Lógica de UI
        } else if (orcamento.ehUrgente) {
          corBordaPrincipal = AppColors.error;
        } else if (orcamento.ehRetorno) {
          corBordaPrincipal = AppColors.success;
        } else if (isAtrasado) {
          corBordaPrincipal = AppColors.warning;
        } else {
          corBordaPrincipal = corSecundaria;
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
              widget.isAdmin ? "Detalhes do Orçamento" : "Detalhes do Serviço",
            ),
            backgroundColor: corPrincipal,
            centerTitle: true,
            actions: widget.isAdmin
                ? [
                    IconButton(
                      icon: const Icon(AppIcons.excluir),
                      onPressed: _excluirOrcamento,
                      tooltip: 'Excluir Orçamento',
                    ),
                  ]
                : [],
          ),
          floatingActionButton: widget.isAdmin
              ? FloatingActionButton(
                  backgroundColor: corPrincipal,
                  foregroundColor: AppColors.textPrimary,
                  onPressed: _navegarEditar,
                  tooltip: 'Editar Orçamento',
                  child: const Icon(AppIcons.editar),
                )
              : null,
          body: _buildBody(
            _controller,
            corBordaPrincipal,
            textoValor,
            corValor,
            horario,
            iconHorario,
            corHorario,
          ),
        );
      },
    );
  }

  /// Constrói o corpo da tela, gerenciando os estados de carregamento e erro.
  Widget _buildBody(
    DetalhesOrcamentoController controller,
    Color corBordaPrincipal,
    String textoValor,
    Color corValor,
    String horario,
    IconData iconHorario,
    Color corHorario,
  ) {
    if (controller.isLoading && controller.error == null) {
      return Center(child: CircularProgressIndicator(color: corPrincipal));
    }

    if (controller.error != null) {
      return AppErrorView(
        message: controller.error!,
        buttonText: "Tentar Novamente",
        onTryAgain: controller.carregarDetalhes,
      );
    }

    final orcamento = controller.orcamento;

    return RefreshIndicator(
      color: corPrincipal,
      backgroundColor: AppColors.cardBackground,
      onRefresh: controller.carregarDetalhes,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spaceLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PrincipalInfoCard(
              orcamento: orcamento,
              borderColor: corBordaPrincipal,
              secondaryColor: corSecundaria,
            ),
            const SizedBox(height: AppDimensions.spaceMedium),
            if (widget.isAdmin) ...[
              ValorCard(textoValor: textoValor, corValor: corValor),
              const SizedBox(height: AppDimensions.spaceLarge),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: ClienteButton(
                    nomeCliente:
                        orcamento.cliente?.nome ?? 'Cliente desconhecido',
                    themeColor: corPrincipal,
                    onTap: _navegarDetalhesCliente,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceMedium),
                Expanded(
                  flex: 2,
                  child: InfoTile(
                    label: "TURNO",
                    value: horario.toUpperCase(),
                    icon: iconHorario,
                    color: corHorario,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceMedium),
            if (widget.isAdmin) ...[
              StatusActionCard(
                orcamento: orcamento,
                onStatusChange: _alterarStatusEntrega,
              ),
              const SizedBox(height: AppDimensions.spaceLarge),
            ],
            Row(
              children: [
                Expanded(
                  child: DataCard(
                    label: "Entrada",
                    data: orcamento.dataPega,
                    icon: AppIcons.calendario,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceMedium),
                Expanded(
                  child: DataCard(
                    label: "Entrega",
                    data: orcamento.dataEntrega,
                    icon: AppIcons.evento,
                    color: orcamento.isAtrasado
                        ? AppColors.error
                        : AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceXXXLarge),
          ],
        ),
      ),
    );
  }
}
