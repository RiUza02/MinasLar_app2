import '../../Core/Design/design_system.dart';
import '../../Core/Widgets/widgets.dart';
import '../../Features/Modelos/cliente_model.dart';
import '../../Features/Repositorios/orcamento_repository.dart';
import '../Utils/ListaOrcamento/adicionar_orcamento_controller.dart';
import '../Utils/ListaOrcamento/widgets.dart';

/// Tela responsável pelo cadastro de novos orçamentos vinculados a um cliente.
class AdicionarOrcamento extends StatefulWidget {
  final Cliente cliente;
  final DateTime? dataSelecionada;

  const AdicionarOrcamento({
    super.key,
    required this.cliente,
    this.dataSelecionada,
  });

  @override
  State<AdicionarOrcamento> createState() => _AdicionarOrcamentoState();
}

class _AdicionarOrcamentoState extends State<AdicionarOrcamento> {
  late final AdicionarOrcamentoController _controller;

  // ==================================================
  // CICLO DE VIDA
  // ==================================================
  @override
  void initState() {
    super.initState();
    _controller = AdicionarOrcamentoController(
      cliente: widget.cliente,
      repository: OrcamentoRepository(),
      dataSelecionada: widget.dataSelecionada,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ==================================================
  // LÓGICA DE NEGÓCIO
  // ==================================================
  Future<void> _selecionarData({required bool isEntrega}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isEntrega
          ? (_controller.dataEntrega ?? _controller.dataPega)
          : _controller.dataPega,
      firstDate: isEntrega
          ? DateUtils.dateOnly(_controller.dataPega)
          : DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: AppTheme.darkTheme.copyWith(
            colorScheme: AppTheme.darkTheme.colorScheme.copyWith(
              primary: AppColors.primaryAlternative,
              surface: AppColors.cardBackground,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) _controller.setData(picked, isEntrega: isEntrega);
  }

  Future<void> _salvarOrcamento() async {
    final resultado = await _controller.salvarOrcamento();

    if (!mounted) return;

    if (resultado == null) {
      // Sucesso
      AppFeedback.show(
        context,
        'Orçamento adicionado com sucesso!',
        type: FeedbackType.success,
      );
      Navigator.pop(context, true);
    } else if (resultado.isNotEmpty) {
      // Erro
      AppFeedback.show(context, resultado, type: FeedbackType.error);
    }
  }

  // ==================================================
  // INTERFACE PRINCIPAL (BUILD)
  // ==================================================
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text("Novo Orçamento"),
            backgroundColor: AppColors.primaryAlternative,
            centerTitle: true,
          ),
          bottomNavigationBar: AdicionarOrcamentoBottomBar(
            isLoading: _controller.isLoading,
            onPressed: _salvarOrcamento,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.spaceLarge),
            child: Form(
              key: _controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClienteHeader(cliente: widget.cliente),
                  const SizedBox(height: AppDimensions.spaceXLarge),
                  StatusCard(controller: _controller),
                  const SizedBox(height: AppDimensions.spaceLarge),
                  ServicoCard(
                    tituloController: _controller.tituloController,
                    descricaoController: _controller.descricaoController,
                  ),
                  const SizedBox(height: AppDimensions.spaceMedium),
                  FinanceiroCard(valorController: _controller.valorController),
                  const SizedBox(height: AppDimensions.spaceMedium),
                  PrazosCard(
                    controller: _controller,
                    onSelectDate: _selecionarData,
                  ),
                  const SizedBox(height: AppDimensions.spaceXXXLarge),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
