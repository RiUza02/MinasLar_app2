import 'package:intl/intl.dart';
import '../../Core/Design/design_system.dart';
import '../../Core/Errors/errors.dart';
import '../../Core/Utils/formatters.dart';
import '../../Core/Widgets/widgets.dart';
import '../../Features/Modelos/orcamento_model.dart';
import '../../Features/Repositorios/orcamento_repository.dart';
import '../Cliente/detalha_cliente.dart';
import 'edita_orcamento.dart';

/// [Visão Geral]
/// Tela de detalhamento completo e gerenciamento de um orçamento individual.
///
/// [Uso]
/// Exibir informações detalhadas, atualizar status de conclusão, editar ou excluir
/// um orçamento. Aceita dados no parâmetro [orcamentoInicial] como modelo [Orcamento] ou [Map].
class DetalhesOrcamento extends StatefulWidget {
  final dynamic orcamentoInicial;
  final bool isAdmin;

  const DetalhesOrcamento({
    super.key,
    required this.orcamentoInicial,
    this.isAdmin = false,
  });

  @override
  State<DetalhesOrcamento> createState() => _DetalhesOrcamentoState();
}

class _DetalhesOrcamentoState extends State<DetalhesOrcamento> {
  // [Gerenciamento de Estado e Repositório]
  final _repository = OrcamentoRepository();
  late Orcamento _orcamento;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // [Normalização de Dados] Aceita tanto instância da model quanto Map vindo de APIs (ex: Supabase)
    if (widget.orcamentoInicial is Orcamento) {
      _orcamento = widget.orcamentoInicial as Orcamento;
    } else if (widget.orcamentoInicial is Map) {
      _orcamento = Orcamento.fromMap(
        Map<String, dynamic>.from(widget.orcamentoInicial as Map),
      );
    } else {
      throw ArgumentError(
        'O argumento orcamentoInicial deve ser um Orcamento ou um Map<String, dynamic>.',
      );
    }
    _carregarDetalhes();
  }

  /// [Ação] Rebusca os dados atualizados do orçamento diretamente do repositório.
  Future<void> _carregarDetalhes() async {
    if (_orcamento.id == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final atualizado = await _repository.buscarOrcamentoPorId(_orcamento.id!);
      if (mounted) {
        setState(() => _orcamento = atualizado);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = ErrorHandler.mapearErro(e));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// [Ação] Alterna o status de conclusão/entrega do serviço e persiste a mudança.
  Future<void> _alterarStatusEntrega() async {
    setState(() => _isLoading = true);
    try {
      final orcamentoAtualizado = _orcamento.copyWith(
        entregue: !_orcamento.entregue,
      );
      await _repository.salvarOrcamento(orcamentoAtualizado);

      setState(() => _orcamento = orcamentoAtualizado);
      if (mounted) {
        AppFeedback.show(
          context,
          orcamentoAtualizado.entregue
              ? 'Serviço marcado como concluído!'
              : 'Serviço reaberto com sucesso!',
          type: FeedbackType.success,
        );
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
      await _carregarDetalhes();
    }
  }

  /// [Ação] Exibe modal de confirmação e realiza a exclusão definitiva do registro.
  Future<void> _excluirOrcamento() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          "Excluir Orçamento?",
          style: AppTextStyles.titleMedium,
        ),
        content: const Text(
          "Esta ação não poderá ser desfeita.",
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              "CANCELAR",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("EXCLUIR", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar != true || _orcamento.id == null) return;

    setState(() => _isLoading = true);
    try {
      await _repository.excluirOrcamento(_orcamento.id!);
      if (mounted) {
        AppFeedback.show(
          context,
          'Orçamento removido.',
          type: FeedbackType.success,
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.show(
          context,
          ErrorHandler.mapearErro(e),
          type: FeedbackType.error,
        );
        setState(() => _isLoading = false);
      }
    }
  }

  /// [Navegação] Abre o formulário de edição e atualiza a tela caso ocorram alterações.
  Future<void> _editarOrcamento() async {
    final editado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditarOrcamento(orcamento: _orcamento.toMap()),
      ),
    );
    if (editado == true && mounted) {
      _carregarDetalhes();
    }
  }

  /// [Regra de Negócio]
  /// Calcula e retorna o status de maior prioridade para exibição visual (Rótulo, Cor e Ícone).
  ({String label, Color color, IconData icon}) _obterStatusPrincipal() {
    if (_orcamento.entregue) {
      return (
        label: "CONCLUÍDO",
        color: AppColors.primary,
        icon: AppIcons.valido,
      );
    }
    if (_orcamento.isAtrasado) {
      return (
        label: "ATRASADO",
        color: AppColors.warning,
        icon: AppIcons.pendente,
      );
    }
    if (_orcamento.ehUrgente) {
      return (label: "URGENTE", color: AppColors.error, icon: AppIcons.urgente);
    }
    if (_orcamento.ehRetorno) {
      return (
        label: "GARANTIA",
        color: AppColors.adminColor,
        icon: AppIcons.retorno,
      );
    }
    return (
      label: "PENDENTE",
      color: AppColors.morningShift,
      icon: AppIcons.pendente,
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = _obterStatusPrincipal();

    // [Formatação de Dados para Exibição]
    final dataEntradaF = DateFormat('dd/MM/yyyy').format(_orcamento.dataPega);
    final dataEntregaF = _orcamento.dataEntrega != null
        ? DateFormat('dd/MM/yyyy').format(_orcamento.dataEntrega!)
        : 'A Definir';
    final valorF = _orcamento.valor != null
        ? NumberFormat.currency(
            locale: 'pt_BR',
            symbol: 'R\$ ',
          ).format(_orcamento.valor)
        : 'A Combinar';

    return Scaffold(
      backgroundColor: AppColors.background,

      // [Barra de Ações Superior]
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40.0),
        child: AppBar(
          title: const Text("Detalhes do Orçamento"),
          backgroundColor: widget.isAdmin
              ? AppColors.primaryAlternative
              : AppColors.primary,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(AppIcons.editar, color: AppColors.textPrimary),
              onPressed: _isLoading ? null : _editarOrcamento,
              tooltip: "Editar",
            ),
            IconButton(
              icon: const Icon(AppIcons.excluir, color: AppColors.textPrimary),
              onPressed: _isLoading ? null : _excluirOrcamento,
              tooltip: "Excluir",
            ),
          ],
        ),
      ),
      body: _isLoading && _orcamento.id == null
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryAlternative,
              ),
            )
          : _error != null
          ? AppErrorView(
              message: _error!,
              buttonText: 'Tentar Novamente',
              onTryAgain: _carregarDetalhes,
            )
          : RefreshIndicator(
              onRefresh: _carregarDetalhes,
              color: AppColors.primaryAlternative,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppDimensions.spaceLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // [Seção] Rótulo de Status Visual e Ação Rápida de Conclusão
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppDimensions.spaceMedium,
                              horizontal: AppDimensions.spaceLarge,
                            ),
                            decoration: BoxDecoration(
                              color: status.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusLarge,
                              ),
                              border: Border.all(color: status.color),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  status.icon,
                                  color: status.color,
                                  size: AppDimensions.iconSizeMedium,
                                ),
                                const SizedBox(width: AppDimensions.spaceSmall),
                                Text(
                                  status.label,
                                  style: AppTextStyles.bodyLargeBold.copyWith(
                                    color: status.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spaceMedium),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusLarge,
                            ),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              AppIcons.atualizar,
                              color: AppColors.textSecondary,
                            ),
                            tooltip: "Alterar Status (Concluir/Reabrir)",
                            onPressed: _isLoading
                                ? null
                                : _alterarStatusEntrega,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spaceLarge),

                    // [Seção] Detalhes e Descrição do Serviço
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.spaceXLarge),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusLarge,
                        ),
                        border: Border(
                          left: BorderSide(color: status.color, width: 6),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _orcamento.titulo,
                            style: AppTextStyles.titleLarge.copyWith(
                              decoration: _orcamento.entregue
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: AppColors.textDisabled,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spaceLarge),
                          const Divider(color: AppColors.borderLight),
                          const SizedBox(height: AppDimensions.spaceLarge),
                          Row(
                            children: [
                              Icon(
                                _orcamento.ehRetorno
                                    ? AppIcons.retorno
                                    : AppIcons.descricao,
                                color: _orcamento.ehRetorno
                                    ? AppColors.adminColor
                                    : AppColors.primaryAlternative,
                                size: AppDimensions.iconSizeSmall,
                              ),
                              const SizedBox(width: AppDimensions.spaceSmall),
                              Text(
                                _orcamento.ehRetorno
                                    ? "GARANTIA / RETORNO"
                                    : "DESCRIÇÃO DO SERVIÇO",
                                style: AppTextStyles.cardHeader.copyWith(
                                  color: _orcamento.ehRetorno
                                      ? AppColors.adminColor
                                      : AppColors.primaryAlternative,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.spaceSmall),
                          Text(
                            (_orcamento.descricao?.isNotEmpty ?? false)
                                ? _orcamento.descricao!
                                : "Sem descrição detalhada informada.",
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceLarge),

                    // [Seção] Prazos de Agendamento e Turno
                    Row(
                      children: [
                        Expanded(
                          child: _buildTile(
                            "ENTRADA",
                            dataEntradaF,
                            AppIcons.calendario,
                            AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spaceMedium),
                        Expanded(
                          child: _buildTile(
                            "ENTREGA",
                            dataEntregaF,
                            AppIcons.evento,
                            _orcamento.isAtrasado
                                ? AppColors.warning
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spaceMedium),
                        Expanded(
                          child: _buildTile(
                            "TURNO",
                            _orcamento.horarioDoDia.valor.toUpperCase(),
                            _orcamento.horarioDoDia == Turno.manha
                                ? AppIcons.manha
                                : AppIcons.tarde,
                            _orcamento.horarioDoDia == Turno.manha
                                ? AppColors.morningShift
                                : AppColors.afternoonShift,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spaceLarge),

                    // [Seção] Resumo Financeiro
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.spaceLarge,
                        horizontal: AppDimensions.spaceXLarge,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusLarge,
                        ),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("VALOR TOTAL", style: AppTextStyles.cardHeader),
                          Text(
                            valorF,
                            style: AppTextStyles.titleLarge.copyWith(
                              color: _orcamento.valor != null
                                  ? AppColors.success
                                  : AppColors.textDisabled,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_orcamento.taxaEntrega != null &&
                        _orcamento.taxaEntrega! > 0)
                      Container(
                        margin: const EdgeInsets.only(
                          top: AppDimensions.spaceLarge,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.spaceLarge,
                          horizontal: AppDimensions.spaceXLarge,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusLarge,
                          ),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "TAXA DE VISITA",
                              style: AppTextStyles.cardHeader,
                            ),
                            Text(
                              NumberFormat.currency(
                                locale: 'pt_BR',
                                symbol: 'R\$ ',
                              ).format(_orcamento.taxaEntrega!),
                              style: AppTextStyles.titleLarge.copyWith(
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: AppDimensions.spaceLarge),

                    // [Seção] Informações e Navegação para o Cliente Vinculado
                    if (_orcamento.cliente != null) ...[
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetalhesClientePage(
                                cliente: _orcamento.cliente!,
                              ),
                            ),
                          ),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusLarge,
                          ),
                          child: AppCardContainer(
                            titulo: 'CLIENTE VINCULADO',
                            icone: AppIcons.clientes,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundColor: AppColors.inputBackground,
                                    child: Icon(
                                      AppIcons.cliente,
                                      color: AppColors.primaryAlternative,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: AppDimensions.spaceMedium,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _orcamento.cliente!.nome,
                                          style: AppTextStyles.bodyLargeBold,
                                        ),
                                        Text(
                                          AppFormatters.telefone.maskText(
                                            _orcamento.cliente!.telefone,
                                          ),
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    AppIcons.navegar,
                                    color: AppColors.textDisabled,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  /// [Componente Auxiliar] Card compacto para exibição individual de datas ou turnos.
  Widget _buildTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceMedium),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: AppDimensions.iconSizeMedium),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 10,
              color: AppColors.textDisabled,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
