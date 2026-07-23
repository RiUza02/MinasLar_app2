import 'package:flutter/material.dart';
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

/// [Objetivo] Tela responsável pelo cadastro e importação de novos clientes.
///
/// [Fluxo] Permite a inserção manual de dados ou importação via parser de texto.
/// Realiza validações de duplicidade no banco antes da persistência e redireciona
/// para a criação de orçamento caso um cliente similar já exista.
class AdicionarClientePage extends StatefulWidget {
  const AdicionarClientePage({super.key});

  @override
  State<AdicionarClientePage> createState() => _AdicionarClientePageState();
}

class _AdicionarClientePageState extends State<AdicionarClientePage> {
  // [Chave] Controla a validação global do formulário de cliente.
  final _formKey = GlobalKey<FormState>();

  // [Repositório] Camada de acesso a dados e consultas no banco.
  final _clienteRepository = ClienteRepository();

  // [Controladores] Gerenciam os campos de entrada de dados.
  late final TextEditingController _nomeController;
  late final TextEditingController _ruaController;
  late final TextEditingController _complementoController;
  late final TextEditingController _numeroController;
  late final TextEditingController _bairroController;
  late final TextEditingController _telefoneController;
  late final TextEditingController _cpfController;
  late final TextEditingController _cnpjController;
  late final TextEditingController _observacaoController;

  // [Estados Reativos] Controlam carregamento e lógica de apresentação (PF/PJ/Problemático).
  bool _isLoading = false;
  bool _isPessoaFisica = true;
  bool _isProblematico = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _ruaController = TextEditingController();
    _complementoController = TextEditingController();
    _numeroController = TextEditingController();
    _bairroController = TextEditingController();
    _telefoneController = TextEditingController();
    _cpfController = TextEditingController();
    _cnpjController = TextEditingController();
    _observacaoController = TextEditingController();
  }

  @override
  void dispose() {
    // [Descarte] Libera memória dos controladores ao fechar a tela.
    _nomeController.dispose();
    _ruaController.dispose();
    _complementoController.dispose();
    _numeroController.dispose();
    _bairroController.dispose();
    _telefoneController.dispose();
    _cpfController.dispose();
    _cnpjController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  /// [Objetivo] Inicia o fluxo de salvamento, validando o formulário e checando duplicidade.
  /// [Fluxo] Executa validação de UI, consulta o banco por clientes similares e decide entre criar ou alertar.
  Future<void> _salvarCliente() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus(); // Oculta o teclado operacional.

    try {
      // [Repositório] Consulta se há registro equivalente por Nome, Rua e Número.
      final clienteEncontrado = await _clienteRepository.verificarDuplicado(
        nome: _nomeController.text.trim(),
        rua: _ruaController.text.trim(),
        numero: _numeroController.text.trim(),
      );

      if (!mounted) return;

      if (clienteEncontrado != null) {
        setState(() => _isLoading = false);
        _handleClienteDuplicado(clienteEncontrado);
      } else {
        await _criarNovoCliente();
      }
    } catch (e) {
      if (!mounted) return;
      AppFeedback.show(
        context,
        ErrorHandler.mapearErro(e),
        type: FeedbackType.error,
      );
      setState(() => _isLoading = false);
    }
  }

  /// [Objetivo] Constrói o modelo de dados e o persiste definitivamente no banco de dados.
  Future<void> _criarNovoCliente() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      // [Modelo] Normaliza textos (TitleCase, trim, remoção de máscaras) para padronização no banco.
      final novoCliente = Cliente(
        nome: _nomeController.text.trim().toTitleCase(),
        rua: _ruaController.text.trim().toTitleCase(),
        numero: _numeroController.text.trim(),
        complemento: _complementoController.text.trim().isEmpty
            ? null
            : _complementoController.text.trim().toTitleCase(),
        bairro: _bairroController.text.trim().toTitleCase(),
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

      // [Repositório] Persiste o registro.
      await _clienteRepository.salvarCliente(novoCliente);

      if (!mounted) return;

      AppFeedback.show(
        context,
        'Cliente adicionado com sucesso!',
        type: FeedbackType.success,
      );

      // [Navegação] Retorna 'true' para sinalizar recarga de listas na tela anterior.
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      AppFeedback.show(
        context,
        ErrorHandler.mapearErro(e),
        type: FeedbackType.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// [Objetivo] Abre um modal interativo para colagem e importação em massa de dados via texto.
  Future<void> _mostrarModalImportacao() async {
    final String? textoImportado = await showDialog<String>(
      context: context,
      builder: (context) => const ClienteImportDialog(),
    );

    if (textoImportado != null && textoImportado.isNotEmpty) {
      _processarTextoImportado(textoImportado);
    }
  }

  /// [Objetivo] Processa o texto bruto com o parser e preenche os controladores automaticamente.
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

  /// [Objetivo] Gerencia a decisão do usuário ao se deparar com um cliente potencialmente duplicado.
  /// [Fluxo] Oferece opções para criar o cadastro ignorando o aviso, ou ir direto para o orçamento do cliente existente.
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
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AdicionarOrcamento(cliente: clienteEncontrado),
          ),
        );
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
              // [Ação Secundária] Botão de importação inteligente por texto.
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

              // [Seção 1] Dados Cadastrais e Endereço.
              AppCardContainer(
                titulo: 'DADOS CADASTRAIS',
                icone: AppIcons.dadosPessoaisSection,
                children: [
                  AppTextField(
                    controller: _nomeController,
                    label: 'Nome Completo',
                    icon: AppIcons.nome,
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Campo obrigatório'
                        : null,
                  ),
                  const SizedBox(height: AppDimensions.spaceMedium),
                  AppTextField(
                    controller: _telefoneController,
                    label: 'Telefone',
                    icon: AppIcons.telefone,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [AppFormatters.telefone],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'Campo obrigatório';
                      if (v.length < 15) return 'Telefone incompleto';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.spaceMedium),
                  AppTextField(
                    controller: _ruaController,
                    label: 'Rua',
                    icon: AppIcons.rua,
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Campo obrigatório'
                        : null,
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
                          textInputAction: TextInputAction.next,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Req.' : null,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spaceMedium),
                      Expanded(
                        child: AppTextField(
                          controller: _complementoController,
                          label: 'Apto / Comp.',
                          icon: AppIcons.complemento,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spaceMedium),
                  AppTextField(
                    controller: _bairroController,
                    label: 'Bairro',
                    icon: AppIcons.bairro,
                    textInputAction: TextInputAction.done,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Campo obrigatório'
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spaceLarge),

              // [Seção 2] Documentação (PF / PJ).
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

              // [Seção 3] Status e Observações.
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

              // [Ação Principal] Botão de submissão do formulário com indicador visual.
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAlternative,
                ),
                onPressed: _isLoading ? null : _salvarCliente,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.textPrimary,
                        ),
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
