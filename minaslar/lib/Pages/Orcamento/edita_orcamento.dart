import '../../Core/Design/design_system.dart';
import '../../Core/Widgets/widgets.dart';
import '../../Features/Modelos/orcamento_model.dart';
import '../../Features/Repositorios/orcamento_repository.dart';
import '../Utils/ListaOrcamento/widgets.dart';
import '../Utils/ListaOrcamento/editar_orcamento_controller.dart';

/// Tela de edição de um orçamento existente.
class EditarOrcamento extends StatefulWidget {
  final Map<String, dynamic> orcamento;

  const EditarOrcamento({super.key, required this.orcamento});

  @override
  State<EditarOrcamento> createState() => _EditarOrcamentoState();
}

class _EditarOrcamentoState extends State<EditarOrcamento> {
  // ==================================================
  // CONTROLADORES E ESTADO
  // ==================================================
  late final EditarOrcamentoController _controller;

  // ==================================================
  // CICLO DE VIDA
  // ==================================================
  @override
  void initState() {
    super.initState();
    _controller = EditarOrcamentoController(
      repository: OrcamentoRepository(),
      orcamento: Orcamento.fromMap(widget.orcamento),
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

  Future<void> _salvarEdicao() async {
    final resultado = await _controller.salvarEdicao();

    if (!mounted) return;

    if (resultado == null) {
      AppFeedback.show(
        context,
        'Orçamento atualizado!',
        type: FeedbackType.success,
      );
      Navigator.pop(context, true);
    } else if (resultado.isNotEmpty) {
      AppFeedback.show(
        context,
        'Erro ao atualizar: $resultado',
        type: FeedbackType.error,
      );
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
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(40.0),
            child: AppBar(
              title: const Text("Editar Orçamento"),
              backgroundColor: AppColors.primaryAlternative,
              centerTitle: true,
            ),
          ),
          bottomNavigationBar: _buildBottomBar(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.spaceLarge),
            child: Form(
              key: _controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StatusCard(controller: _controller),
                  const SizedBox(height: AppDimensions.spaceMedium),
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

  // ==================================================
  // WIDGETS AUXILIARES
  // ==================================================

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceLarge),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryAlternative,
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
        ),
        onPressed: _controller.isLoading ? null : _salvarEdicao,
        child: _controller.isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: AppColors.textPrimary,
                  strokeWidth: 2.5,
                ),
              )
            : Text("SALVAR ALTERAÇÕES", style: AppTextStyles.button),
      ),
    );
  }
}
