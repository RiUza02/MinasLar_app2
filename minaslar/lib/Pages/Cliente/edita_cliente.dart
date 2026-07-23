import 'package:flutter/material.dart';

import '../../Core/Design/design_system.dart';
import '../../Core/Errors/errors.dart';
import '../../Core/Utils/formatters.dart';
import '../../Core/Utils/string_extensions.dart';
import '../../Core/Widgets/widgets.dart';
import '../../Features/Modelos/cliente_model.dart';
import '../../Features/Repositorios/cliente_repository.dart';
import '../Utils/Cliente/tipo_pessoa_selector.dart';

/// [Objetivo] Tela de edição dos dados cadastrais e preferências de um cliente existente.
///
/// [Fluxo] Preenche os campos do formulário com os dados atuais do cliente,
/// valida as informações inseridas (endereço, contato, CPF/CNPJ e observações),
/// persiste as alterações no banco via repositório e retorna a instância atualizada do [Cliente].
class EditarClientePage extends StatefulWidget {
  final Cliente cliente;

  const EditarClientePage({super.key, required this.cliente});

  @override
  State<EditarClientePage> createState() => _EditarClientePageState();
}

class _EditarClientePageState extends State<EditarClientePage> {
  final _formKey = GlobalKey<FormState>();

  // [Repositório] Instância responsável pela comunicação com a camada de dados do cliente.
  final _clienteRepository = ClienteRepository();

  // Controladores do Formulário
  late final TextEditingController _nomeController;
  late final TextEditingController _ruaController;
  late final TextEditingController _complementoController;
  late final TextEditingController _numeroController;
  late final TextEditingController _bairroController;
  late final TextEditingController _telefoneController;
  late final TextEditingController _cpfController;
  late final TextEditingController _cnpjController;
  late final TextEditingController _observacaoController;

  // [Estado Local] Controle do estado de carregamento, seleção de pessoa e flag de alerta.
  bool _isLoading = false;
  late bool _isPessoaFisica;
  late bool _isProblematico;

  @override
  void initState() {
    super.initState();
    final cliente = widget.cliente;

    // Inicialização dos controladores com máscaras e formatação apropriada
    _nomeController = TextEditingController(text: cliente.nome);
    _ruaController = TextEditingController(text: cliente.rua);
    _complementoController = TextEditingController(
      text: cliente.complemento ?? '',
    );
    _numeroController = TextEditingController(text: cliente.numero);
    _bairroController = TextEditingController(text: cliente.bairro);
    _telefoneController = TextEditingController(
      text: AppFormatters.telefone.maskText(cliente.telefone),
    );
    _cpfController = TextEditingController(
      text: cliente.cpf != null ? AppFormatters.cpf.maskText(cliente.cpf!) : '',
    );
    _cnpjController = TextEditingController(
      text: cliente.cnpj != null
          ? AppFormatters.cnpj.maskText(cliente.cnpj!)
          : '',
    );
    _observacaoController = TextEditingController(
      text: cliente.observacao ?? '',
    );

    // Definição do estado inicial
    _isProblematico = cliente.clienteProblematico;
    _isPessoaFisica = (cliente.cnpj == null || cliente.cnpj!.isEmpty);
  }

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

  /// [Objetivo] Processa e valida os dados do formulário, disparando a atualização no banco.
  Future<void> _salvarAlteracoes() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.cliente.id == null) return;

    setState(() => _isLoading = true);

    try {
      final dadosAtualizados = {
        'nome': _nomeController.text.toTitleCase(),
        'rua': _ruaController.text.toTitleCase(),
        'numero': _numeroController.text.trim(),
        'complemento': _complementoController.text.trim().isEmpty
            ? null
            : _complementoController.text.toTitleCase(),
        'bairro': _bairroController.text.toTitleCase(),
        'telefone': AppFormatters.telefone.unmaskText(_telefoneController.text),
        'cpf': _isPessoaFisica && _cpfController.text.isNotEmpty
            ? AppFormatters.cpf.unmaskText(_cpfController.text)
            : null,
        'cnpj': !_isPessoaFisica && _cnpjController.text.isNotEmpty
            ? AppFormatters.cnpj.unmaskText(_cnpjController.text)
            : null,
        'observacao': _observacaoController.text.trim().isEmpty
            ? null
            : _observacaoController.text.trim(),
        'cliente_problematico': _isProblematico,
      };

      await _clienteRepository.atualizarCliente(
        widget.cliente.id!,
        dadosAtualizados,
      );

      if (!mounted) return;

      AppFeedback.show(
        context,
        'Cliente atualizado com sucesso!',
        type: FeedbackType.success,
      );

      final clienteAtualizado = widget.cliente.copyWith(
        nome: dadosAtualizados['nome'] as String,
        rua: dadosAtualizados['rua'] as String,
        numero: dadosAtualizados['numero'] as String,
        complemento: dadosAtualizados['complemento'] as String?,
        bairro: dadosAtualizados['bairro'] as String,
        telefone: dadosAtualizados['telefone'] as String,
        cpf: dadosAtualizados['cpf'] as String?,
        cnpj: dadosAtualizados['cnpj'] as String?,
        observacao: dadosAtualizados['observacao'] as String?,
        clienteProblematico: dadosAtualizados['cliente_problematico'] as bool,
      );

      // [Navegação] Retorna para a tela de detalhes enviando a instância atualizada do cliente.
      Navigator.pop(context, clienteAtualizado);
    } catch (e) {
      if (!mounted) return;
      AppFeedback.show(
        context,
        ErrorHandler.mapearErro(e),
        type: FeedbackType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // [Barra de Título] AppBar padronizada para telas secundárias/edição.
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40.0),
        child: AppBar(
          title: const Text("Editar Cliente"),
          backgroundColor: AppColors.primaryAlternative,
          centerTitle: true,
        ),
      ),

      // [Corpo] Formulário rolável dividido por cards de seção.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spaceLarge),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // [UI] Seção de Dados Cadastrais e Endereço
              AppCardContainer(
                titulo: 'DADOS CADASTRAIS',
                icone: AppIcons.dadosPessoaisSection,
                children: [
                  AppTextField(
                    controller: _nomeController,
                    label: 'Nome Completo',
                    icon: AppIcons.nome,
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
                    inputFormatters: [AppFormatters.telefone],
                    validator: (v) => (v == null || v.length < 15)
                        ? 'Telefone incompleto'
                        : null,
                  ),
                  const SizedBox(height: AppDimensions.spaceMedium),
                  AppTextField(
                    controller: _ruaController,
                    label: 'Rua',
                    icon: AppIcons.rua,
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
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spaceMedium),
                  AppTextField(
                    controller: _bairroController,
                    label: 'Bairro',
                    icon: AppIcons.bairro,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Campo obrigatório'
                        : null,
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.spaceLarge),

              // [UI] Seção de Documentação (PF / PJ)
              AppCardContainer(
                titulo: 'DOCUMENTAÇÃO (OPCIONAL)',
                icone: AppIcons.documento,
                children: [
                  TipoPessoaSelector(
                    isPessoaFisica: _isPessoaFisica,
                    onChanged: (isPf) {
                      setState(() {
                        _isPessoaFisica = isPf;
                        if (isPf) {
                          _cnpjController.clear();
                        } else {
                          _cpfController.clear();
                        }
                      });
                    },
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

              // [UI] Seção de Status e Observações Internas
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

              // [UI] Botão de Confirmação das Alterações
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAlternative,
                ),
                onPressed: _isLoading ? null : _salvarAlteracoes,
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: AppColors.textPrimary,
                      )
                    : const Text("SALVAR ALTERAÇÕES"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
