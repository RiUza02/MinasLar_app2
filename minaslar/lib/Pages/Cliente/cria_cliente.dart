import '../../Core/Design/design_system.dart';
import '../../Core/Errors/errors.dart';
import '../../Core/Utils/formatters.dart';
import '../../Core/Utils/string_extensions.dart';
import '../../Core/Widgets/widgets.dart';
import '../Utils/Cliente/cliente_import_parser.dart';
import '../Utils/Cliente/cliente_duplicado_dialog.dart';
import '../Utils/Cliente/cliente_import_dialog.dart';
import '../Utils/Cliente/tipo_pessoa_selector.dart';
import '../Orcamento/cria_orcamento.dart';
import '../../Features/Modelos/cliente_model.dart';
import '../../Features/Repositorios/cliente_repository.dart';

class AdicionarClientePage extends StatefulWidget {
  const AdicionarClientePage({super.key});

  @override
  State<AdicionarClientePage> createState() => _AdicionarClientePageState();
}

class _AdicionarClientePageState extends State<AdicionarClientePage> {
  final _formKey = GlobalKey<FormState>();
  final _clienteRepository = ClienteRepository();
  bool _isLoading = false;

  // Controladores
  final _nomeController = TextEditingController();
  final _ruaController = TextEditingController();
  final _complementoController = TextEditingController();
  final _numeroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _cpfController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _observacaoController = TextEditingController();

  // Estado
  bool _isPessoaFisica = true;
  bool _isProblematico = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _ruaController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _bairroController.dispose();
    _telefoneController.dispose();
    _cpfController.dispose();
    _cnpjController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  /// Inicia o fluxo de salvamento, validando o formulário e checando duplicidade.
  Future<void> _salvarCliente() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);

    final clienteEncontrado = await _clienteRepository.verificarDuplicado(
      nome: _nomeController.text,
      rua: _ruaController.text,
      numero: _numeroController.text,
    );

    if (mounted) {
      if (clienteEncontrado != null) {
        setState(() => _isLoading = false);
        _handleClienteDuplicado(clienteEncontrado);
      } else {
        await _criarNovoCliente();
      }
    }
  }

  /// Verifica no banco se já existe um cliente com dados parecidos.
  Future<void> _criarNovoCliente() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final novoCliente = Cliente(
        nome: _nomeController.text.toTitleCase(),
        rua: _ruaController.text.toTitleCase(),
        numero: _numeroController.text.trim(),
        complemento: _complementoController.text.trim().isEmpty
            ? null
            : _complementoController.text.toTitleCase(),
        bairro: _bairroController.text.toTitleCase(),
        telefone: AppFormatters.telefone.unmaskText(_telefoneController.text),
        cpf: _isPessoaFisica && _cpfController.text.isNotEmpty
            ? AppFormatters.cpf.unmaskText(_cpfController.text)
            : null,
        cnpj: !_isPessoaFisica && _cnpjController.text.isNotEmpty
            ? AppFormatters.cnpj.unmaskText(_cnpjController.text)
            : null,
        observacao: _observacaoController.text.trim().isEmpty
            ? null
            : _observacaoController.text.trim(),
        clienteProblematico: _isProblematico,
      );

      await _clienteRepository.salvarCliente(novoCliente);

      if (mounted) {
        AppFeedback.show(
          context,
          'Cliente adicionado com sucesso!',
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

  /// Abre um modal para importação de dados via texto.
  Future<void> _mostrarModalImportacao() async {
    final String? textoImportado = await showDialog<String>(
      context: context,
      builder: (context) => const ClienteImportDialog(),
    );

    if (textoImportado != null) {
      _processarTextoImportado(textoImportado);
    }
  }

  /// Processa o texto colado e preenche os campos do formulário.
  void _processarTextoImportado(String texto) {
    try {
      final parser = ClienteImportParser();
      final data = parser.parse(texto);

      setState(() {
        if (data.nome != null) _nomeController.text = data.nome!;
        if (data.telefone != null) {
          _telefoneController.text = AppFormatters.telefone.maskText(
            data.telefone!,
          );
        }
        if (data.rua != null) _ruaController.text = data.rua!;
        if (data.numero != null) _numeroController.text = data.numero!;
        if (data.bairro != null) _bairroController.text = data.bairro!;
      });

      AppFeedback.show(
        context,
        "Dados importados com sucesso!",
        type: FeedbackType.success,
      );
    } on ValidationException catch (e) {
      AppFeedback.show(context, e.message, type: FeedbackType.error);
    }
  }

  /// Mostra um diálogo de confirmação quando um cliente parecido é encontrado.
  Future<void> _handleClienteDuplicado(Cliente clienteEncontrado) async {
    final action = await showDialog<ClienteDuplicadoAction>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          ClienteDuplicadoDialog(clienteEncontrado: clienteEncontrado),
    );

    switch (action) {
      case ClienteDuplicadoAction.criarMesmoAssim:
        await _criarNovoCliente();
        break;
      case ClienteDuplicadoAction.criarOrcamento:
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AdicionarOrcamento(cliente: clienteEncontrado),
            ),
          );
        }
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40.0),
        child: AppBar(
          title: const Text("Novo Cliente"),
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
              OutlinedButton.icon(
                onPressed: _mostrarModalImportacao,
                icon: const Icon(AppIcons.importar),
                label: const Text("Importar Dados de Texto"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryAlternative,
                  side: const BorderSide(color: AppColors.primaryAlternative),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.spaceMedium,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spaceXLarge),
              AppCardContainer(
                titulo: 'DADOS CADASTRAIS',
                icone: AppIcons.dadosPessoaisSection,
                children: [
                  AppTextField(
                    controller: _nomeController,
                    label: 'Nome Completo',
                    icon: AppIcons.nome,
                    validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: AppDimensions.spaceMedium),
                  AppTextField(
                    controller: _telefoneController,
                    label: 'Telefone',
                    icon: AppIcons.telefone,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [AppFormatters.telefone],
                    validator: (v) =>
                        v!.length < 15 ? 'Telefone incompleto' : null,
                  ),
                  const SizedBox(height: AppDimensions.spaceMedium),
                  AppTextField(
                    controller: _ruaController,
                    label: 'Rua',
                    icon: AppIcons.rua,
                    validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: AppDimensions.spaceMedium),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _numeroController,
                          label: 'Nº',
                          icon: AppIcons.numeroCasa,
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Req.' : null,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spaceMedium),
                      Expanded(
                        child: AppTextField(
                          controller: _complementoController,
                          label: 'Apto / Comp.',
                          icon: AppIcons.complemento,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spaceMedium),
                  AppTextField(
                    controller: _bairroController,
                    label: 'Bairro',
                    icon: AppIcons.bairro,
                    validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spaceLarge),
              AppCardContainer(
                titulo: 'DOCUMENTAÇÃO (OPCIONAL)',
                icone: AppIcons.documento,
                children: [
                  TipoPessoaSelector(
                    isPessoaFisica: _isPessoaFisica,
                    onChanged: (isPf) => setState(() => _isPessoaFisica = isPf),
                  ),
                  const SizedBox(height: AppDimensions.spaceLarge),
                  AnimatedCrossFade(
                    firstChild: AppTextField(
                      label: "CPF (Opcional)",
                      controller: _cpfController,
                      icon: AppIcons.documento,
                      keyboardType: TextInputType.number,
                      inputFormatters: [AppFormatters.cpf],
                      validator: (v) =>
                          (v != null && v.isNotEmpty && v.length < 14)
                          ? 'CPF incompleto'
                          : null,
                    ),
                    secondChild: AppTextField(
                      label: "CNPJ (Opcional)",
                      controller: _cnpjController,
                      icon: AppIcons.empresa,
                      keyboardType: TextInputType.number,
                      inputFormatters: [AppFormatters.cnpj],
                      validator: (v) =>
                          (v != null && v.isNotEmpty && v.length < 18)
                          ? 'CNPJ incompleto'
                          : null,
                    ),
                    crossFadeState: _isPessoaFisica
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    duration: const Duration(milliseconds: 300),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spaceLarge),
              AppCardContainer(
                titulo: 'STATUS E OBSERVAÇÕES',
                icone: AppIcons.info,
                children: [
                  SwitchListTile(
                    activeThumbColor: AppColors.error,
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      "Cliente Problemático?",
                      style: AppTextStyles.bodyMedium,
                    ),
                    subtitle: Text(
                      "Marque se houver histórico de problemas",
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textDisabled,
                      ),
                    ),
                    value: _isProblematico,
                    onChanged: (val) => setState(() => _isProblematico = val),
                  ),
                  const Divider(color: AppColors.borderLight),
                  const SizedBox(height: AppDimensions.spaceMedium),
                  AppTextField(
                    label: "Observações (Opcional)",
                    controller: _observacaoController,
                    icon: AppIcons.observacao,
                    maxLines: 3,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spaceXXLarge),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAlternative,
                ),
                onPressed: _isLoading ? null : _salvarCliente,
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: AppColors.textPrimary,
                      )
                    : const Text("CADASTRAR CLIENTE"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
