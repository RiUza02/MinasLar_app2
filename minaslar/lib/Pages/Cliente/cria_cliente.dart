import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../Core/Design/design_system.dart';
import '../../Core/Errors/errors.dart';
import '../../Core/Utils/formatters.dart';
import '../../Core/Widgets/widgets.dart';
import '../../Features/Modelos/cliente_model.dart';

/// Página para cadastro de novos clientes, com validações e checagem de duplicidade.
class AdicionarClientePage extends StatefulWidget {
  const AdicionarClientePage({super.key});

  @override
  State<AdicionarClientePage> createState() => _AdicionarClientePageState();
}

class _AdicionarClientePageState extends State<AdicionarClientePage> {
  final _formKey = GlobalKey<FormState>();
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

  /// Formata um texto para o padrão "Title Case".
  String _formatarTexto(String texto) {
    if (texto.trim().isEmpty) return "";
    return texto
        .trim()
        .split(RegExp(r'\s+'))
        .map((palavra) {
          if (palavra.isEmpty) return "";
          return "${palavra[0].toUpperCase()}${palavra.substring(1).toLowerCase()}";
        })
        .join(' ');
  }

  /// Inicia o fluxo de salvamento, validando o formulário e checando duplicidade.
  Future<void> _salvarCliente() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);

    final clienteEncontrado = await _verificarClienteDuplicado(
      nome: _nomeController.text,
      rua: _ruaController.text,
      numero: _numeroController.text,
    );

    if (mounted) {
      if (clienteEncontrado != null) {
        setState(() => _isLoading = false);
        _mostrarDialogoClienteDuplicado(clienteEncontrado);
      } else {
        await _criarNovoCliente();
      }
    }
  }

  /// Verifica no banco se já existe um cliente com dados parecidos.
  Future<Cliente?> _verificarClienteDuplicado({
    required String nome,
    required String rua,
    required String numero,
  }) async {
    try {
      final response = await Supabase.instance.client
          .from('clientes')
          .select()
          .ilike('nome', '%${nome.trim()}%')
          .ilike('rua', '%${rua.trim()}%')
          .eq('numero', numero.trim())
          .limit(1);

      if (response.isNotEmpty) {
        return Cliente.fromMap(response.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Insere o novo cliente no banco de dados.
  Future<void> _criarNovoCliente() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final novoCliente = Cliente(
        nome: _formatarTexto(_nomeController.text),
        rua: _formatarTexto(_ruaController.text),
        numero: _numeroController.text.trim(),
        complemento: _complementoController.text.trim().isEmpty
            ? null
            : _formatarTexto(_complementoController.text),
        bairro: _formatarTexto(_bairroController.text),
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

      await Supabase.instance.client
          .from('clientes')
          .insert(novoCliente.toMap());

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
  void _mostrarModalImportacao() {
    final importarController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          ),
          title: const Row(
            children: [
              Icon(Icons.paste, color: AppColors.primaryAlternative),
              SizedBox(width: AppDimensions.spaceSmall),
              Text("Importar Dados"),
            ],
          ),
          titleTextStyle: AppTextStyles.titleMedium,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Cole o texto abaixo na seguinte ordem:\n1. Nome\n2. Telefone\n3. Rua\n4. Número\n5. Bairro",
                  style: AppTextStyles.bodyMediumSecondary.copyWith(
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceMedium),
                TextField(
                  controller: importarController,
                  maxLines: 8,
                  style: AppTextStyles.bodyMedium,
                  decoration: InputDecoration(
                    hintText: "Cole o texto aqui...",
                    filled: true,
                    fillColor: AppColors.inputBackground,
                    hintStyle: AppTextStyles.inputHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMedium,
                      ),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                _processarTextoImportado(importarController.text);
                Navigator.pop(context);
              },
              child: const Text("Preencher Campos"),
            ),
          ],
        );
      },
    );
  }

  /// Processa o texto colado e preenche os campos do formulário.
  void _processarTextoImportado(String texto) {
    if (texto.trim().isEmpty) return;

    // Filtra linhas vazias para evitar deslocamento dos índices
    List<String> linhas = texto
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (linhas.length > 1) {
      bool temLetras = RegExp(r'[a-zA-Z]').hasMatch(linhas[1]);
      if (temLetras) {
        AppFeedback.show(
          context,
          "Erro: A 2ª linha (Telefone) contém letras. Corrija para apenas números.",
          type: FeedbackType.error,
        );
        return;
      }
    }

    setState(() {
      if (linhas.isNotEmpty) _nomeController.text = linhas[0];
      if (linhas.length > 1) {
        String telLimpo = linhas[1].replaceAll(RegExp(r'[^0-9]'), '');
        _telefoneController.text = AppFormatters.telefone.maskText(telLimpo);
      }
      if (linhas.length > 2) _ruaController.text = linhas[2];
      if (linhas.length > 3) _numeroController.text = linhas[3];
      if (linhas.length > 4) _bairroController.text = linhas[4];
    });

    AppFeedback.show(
      context,
      "Dados importados com sucesso!",
      type: FeedbackType.success,
    );
  }

  /// Mostra um diálogo de confirmação quando um cliente parecido é encontrado.
  void _mostrarDialogoClienteDuplicado(Cliente clienteEncontrado) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          ),
          title: const Row(
            children: [
              Icon(Icons.people_alt_outlined, color: Colors.amber),
              SizedBox(width: AppDimensions.spaceSmall),
              Text("Cliente Parecido Encontrado"),
            ],
          ),
          titleTextStyle: AppTextStyles.titleMedium,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Encontramos um cliente com nome e endereço semelhantes:",
                  style: AppTextStyles.bodyMediumSecondary,
                ),
                const SizedBox(height: AppDimensions.spaceLarge),
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spaceMedium),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMedium,
                    ),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clienteEncontrado.nome,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spaceXSmall),
                      Text(
                        "${clienteEncontrado.rua}, ${clienteEncontrado.numero} - ${clienteEncontrado.bairro}",
                        style: AppTextStyles.bodyMediumSecondary,
                      ),
                      const SizedBox(height: AppDimensions.spaceXSmall),
                      Text(
                        AppFormatters.telefone.maskText(
                          clienteEncontrado.telefone,
                        ),
                        style: AppTextStyles.bodyMediumSecondary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceLarge),
                Text(
                  "O que você deseja fazer?",
                  style: AppTextStyles.bodyMediumSecondary,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                _criarNovoCliente();
              },
              child: const Text("Criar Mesmo Assim"),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.add_comment),
              label: const Text("Criar Orçamento"),
            ),
          ],
        );
      },
    );
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
                icon: const Icon(Icons.content_paste_go),
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
                    icon: Icons.add_road,
                    validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: AppDimensions.spaceMedium),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _numeroController,
                          label: 'Nº',
                          icon: Icons.home_filled,
                          keyboardType: TextInputType.text,
                          validator: (v) => v!.isEmpty ? 'Req.' : null,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spaceMedium),
                      Expanded(
                        child: AppTextField(
                          controller: _complementoController,
                          label: 'Apto / Comp.',
                          icon: Icons.apartment,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spaceMedium),
                  AppTextField(
                    controller: _bairroController,
                    label: 'Bairro',
                    icon: Icons.location_city,
                    validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spaceLarge),
              AppCardContainer(
                titulo: 'DOCUMENTAÇÃO (OPCIONAL)',
                icone: Icons.badge_outlined,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMedium,
                      ),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildRadioButton("Pessoa Física", true),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppColors.borderLight,
                        ),
                        Expanded(
                          child: _buildRadioButton("Pessoa Jurídica", false),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceLarge),
                  AnimatedCrossFade(
                    firstChild: AppTextField(
                      label: "CPF (Opcional)",
                      controller: _cpfController,
                      icon: Icons.badge_outlined,
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
                      icon: Icons.domain,
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
                icone: Icons.info_outline,
                children: [
                  SwitchListTile(
                    activeColor: AppColors.error,
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
                    icon: Icons.note,
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

  /// Constrói o botão de rádio para seleção de tipo de pessoa.
  Widget _buildRadioButton(String title, bool value) {
    final isSelected = _isPessoaFisica == value;
    return InkWell(
      onTap: () => setState(() => _isPessoaFisica = value),
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spaceMedium,
        ),
        child: Center(
          child: Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected
                  ? AppColors.primaryAlternative
                  : AppColors.textDisabled,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
