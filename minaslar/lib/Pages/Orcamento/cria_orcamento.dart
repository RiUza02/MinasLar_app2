import 'package:intl/intl.dart';
import '../../Core/Design/design_system.dart';
import '../../Core/Errors/errors.dart';
import '../../Core/Utils/formatters.dart';
import '../../Core/Utils/string_extensions.dart';
import '../../Core/Widgets/widgets.dart';
import '../../Features/Modelos/cliente_model.dart';
import '../../Features/Modelos/orcamento_model.dart';
import '../../Features/Repositorios/orcamento_repository.dart';

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
  final _formKey = GlobalKey<FormState>();
  final _repository = OrcamentoRepository();
  bool _isLoading = false;

  // Controladores de Texto
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  final _taxaEntregaController = TextEditingController();

  // Estado Local (Substituindo os antigos Controllers externos)
  late DateTime _dataPega;
  DateTime? _dataEntrega;
  Turno _horarioSelecionado = Turno.manha;
  bool _foiEntregue = false;
  bool _ehUrgente = false;
  bool _ehRetorno = false;

  @override
  void initState() {
    super.initState();
    _dataPega = widget.dataSelecionada ?? DateTime.now();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _valorController.dispose();
    _taxaEntregaController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData({required bool isEntrega}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isEntrega ? (_dataEntrega ?? _dataPega) : _dataPega,
      firstDate: isEntrega ? DateUtils.dateOnly(_dataPega) : DateTime(2020),
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

    if (picked != null && mounted) {
      setState(() {
        if (isEntrega) {
          _dataEntrega = picked;
        } else {
          _dataPega = picked;
          if (_dataEntrega != null && _dataEntrega!.isBefore(_dataPega)) {
            _dataEntrega = null;
          }
        }
      });
    }
  }

  Future<void> _salvarOrcamento() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.cliente.id == null) {
      AppFeedback.show(
        context,
        'Erro: Cliente sem ID.',
        type: FeedbackType.error,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      double? valorFinal;
      if (_valorController.text.isNotEmpty) {
        final limpo = _valorController.text
            .replaceAll('R\$', '')
            .replaceAll('.', '')
            .replaceAll(',', '.')
            .trim();
        valorFinal = double.tryParse(limpo);
      }

      double? taxaEntregaFinal;
      if (_taxaEntregaController.text.isNotEmpty) {
        final limpo = _taxaEntregaController.text
            .replaceAll('R\$', '')
            .replaceAll('.', '')
            .replaceAll(',', '.')
            .trim();
        taxaEntregaFinal = double.tryParse(limpo);
      }

      final novoOrcamento = Orcamento(
        clienteId: widget.cliente.id!,
        cliente: widget.cliente,
        titulo: _tituloController.text.toTitleCase(),
        descricao: _descricaoController.text.trim().isEmpty
            ? null
            : _descricaoController.text.trim(),
        valor: valorFinal,
        taxaEntrega: taxaEntregaFinal,
        dataPega: _dataPega,
        dataEntrega: _dataEntrega,
        horarioDoDia: _horarioSelecionado,
        entregue: _foiEntregue,
        ehUrgente: _ehUrgente,
        ehRetorno: _ehRetorno,
      );

      await _repository.salvarOrcamento(novoOrcamento);

      if (mounted) {
        AppFeedback.show(
          context,
          'Orçamento adicionado com sucesso!',
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
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40.0),
        child: AppBar(
          title: const Text("Novo Orçamento"),
          backgroundColor: AppColors.primaryAlternative,
          centerTitle: true,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spaceLarge),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cabeçalho Simples de Leitura do Cliente
              Container(
                padding: const EdgeInsets.all(AppDimensions.spaceMedium),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMedium,
                  ),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    const Icon(
                      AppIcons.clientes,
                      color: AppColors.primaryAlternative,
                    ),
                    const SizedBox(width: AppDimensions.spaceMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.cliente.nome,
                            style: AppTextStyles.titleMedium,
                          ),
                          Text(
                            AppFormatters.telefone.maskText(
                              widget.cliente.telefone,
                            ),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spaceLarge),

              // DADOS DO SERVIÇO (Absorvendo ServicoCard)
              AppCardContainer(
                titulo: 'DETALHES DO SERVIÇO',
                icone: AppIcons.descricao,
                children: [
                  AppTextField(
                    controller: _tituloController,
                    label: 'Título do Serviço',
                    icon: AppIcons.titulo,
                    validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: AppDimensions.spaceMedium),
                  AppTextField(
                    controller: _descricaoController,
                    label: 'Descrição (Opcional)',
                    icon: AppIcons.descricao,
                    maxLines: 3,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spaceLarge),

              // FINANCEIRO (Absorvendo FinanceiroCard)
              AppCardContainer(
                titulo: 'VALORES E PAGAMENTO',
                icone: AppIcons.valor,
                children: [
                  AppTextField(
                    controller: _valorController,
                    label: 'Valor Total (R\$)',
                    icon: AppIcons.valor,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppDimensions.spaceMedium),
                  AppTextField(
                    controller: _taxaEntregaController,
                    label: 'Taxa de Entrega/Visita (R\$)',
                    icon: Icons.delivery_dining_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spaceLarge),

              // PRAZOS E HORÁRIOS (Absorvendo PrazosCard + seletores de 2º nível)
              AppCardContainer(
                titulo: 'PRAZOS E HORÁRIOS',
                icone: AppIcons.calendario,
                children: [
                  Text('Preferência de Turno', style: AppTextStyles.label),
                  const SizedBox(height: AppDimensions.spaceSmall),
                  Row(
                    children: [
                      _buildTurnoBtn(
                        'Manhã',
                        AppIcons.manha,
                        AppColors.morningShift,
                        Turno.manha,
                      ),
                      const SizedBox(width: AppDimensions.spaceMedium),
                      _buildTurnoBtn(
                        'Tarde',
                        AppIcons.tarde,
                        AppColors.afternoonShift,
                        Turno.tarde,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spaceLarge),
                  const Divider(color: AppColors.borderLight),
                  const SizedBox(height: AppDimensions.spaceLarge),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDataBtn(
                          'Entrada',
                          DateFormat('dd/MM/yyyy').format(_dataPega),
                          AppIcons.calendario,
                          () => _selecionarData(isEntrega: false),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spaceMedium),
                      Expanded(
                        child: _buildDataBtn(
                          'Entrega',
                          _dataEntrega != null
                              ? DateFormat('dd/MM/yyyy').format(_dataEntrega!)
                              : 'Definir...',
                          AppIcons.evento,
                          () => _selecionarData(isEntrega: true),
                          onClear: _dataEntrega != null
                              ? () => setState(() => _dataEntrega = null)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spaceLarge),

              // STATUS DO SERVIÇO (Absorvendo StatusCard)
              AppCardContainer(
                titulo: 'STATUS DO SERVIÇO',
                icone: AppIcons.info,
                children: [
                  SwitchListTile(
                    activeThumbColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      "Serviço Concluído?",
                      style: AppTextStyles.bodyMediumBold,
                    ),
                    value: _foiEntregue,
                    onChanged: (val) => setState(() => _foiEntregue = val),
                  ),
                  const Divider(color: AppColors.borderLight),
                  SwitchListTile(
                    activeThumbColor: AppColors.error,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      "Marcar como Urgente",
                      style: AppTextStyles.bodyMediumBold,
                    ),
                    value: _ehUrgente,
                    onChanged: (val) => setState(() => _ehUrgente = val),
                  ),
                  const Divider(color: AppColors.borderLight),
                  SwitchListTile(
                    activeThumbColor: AppColors.success,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      "Garantia / Retorno",
                      style: AppTextStyles.bodyMediumBold,
                    ),
                    value: _ehRetorno,
                    onChanged: (val) => setState(() => _ehRetorno = val),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spaceXXLarge),

              // Botão Principal (Sem arquivo de BottomBar separado)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAlternative,
                ),
                onPressed: _isLoading ? null : _salvarOrcamento,
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: AppColors.textPrimary,
                      )
                    : const Text("CADASTRAR ORÇAMENTO"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Componentes visuais locais de 1º nível (evita criar arquivos de 2º nível para botões simples)
  Widget _buildTurnoBtn(String texto, IconData icone, Color cor, Turno turno) {
    final isSelected = _horarioSelecionado == turno;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _horarioSelecionado = turno),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.spaceMedium,
          ),
          decoration: BoxDecoration(
            color: isSelected ? cor.withAlpha(51) : AppColors.inputBackground,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(
              color: isSelected ? cor : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icone,
                color: isSelected ? cor : AppColors.textDisabled,
                size: AppDimensions.iconSizeMedium,
              ),
              const SizedBox(width: AppDimensions.spaceSmall),
              Text(
                texto,
                style:
                    (isSelected
                            ? AppTextStyles.bodyMediumBold
                            : AppTextStyles.bodyMedium)
                        .copyWith(
                          color: isSelected ? cor : AppColors.textDisabled,
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataBtn(
    String label,
    String valor,
    IconData icone,
    VoidCallback onTap, {
    VoidCallback? onClear,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceSmall,
              vertical: AppDimensions.spaceMedium,
            ),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                Icon(
                  icone,
                  size: AppDimensions.iconSizeSmall,
                  color: AppColors.primaryAlternative,
                ),
                const SizedBox(width: AppDimensions.spaceSmall),
                Expanded(
                  child: Text(
                    valor,
                    style: AppTextStyles.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onClear != null)
                  GestureDetector(
                    onTap: onClear,
                    child: const Icon(
                      AppIcons.limpar,
                      size: AppDimensions.iconSizeSmall,
                      color: AppColors.error,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
