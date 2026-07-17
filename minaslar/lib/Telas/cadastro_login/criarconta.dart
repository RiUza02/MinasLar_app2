import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/design_system/design_system.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';

/// Tela responsável pelo registro de novos usuários no aplicativo.
///
/// [Fluxo]: Valida os dados de entrada localmente com regras de formatação e
/// feedback visual e, em seguida, realiza a persistência na tabela `usuarios` do Supabase.
class CriarContaPage extends StatefulWidget {
  const CriarContaPage({super.key});

  @override
  State<CriarContaPage> createState() => _CriarContaPageState();
}

class _CriarContaPageState extends State<CriarContaPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores dos campos de texto
  late final TextEditingController _nomeController;
  late final TextEditingController _telefoneController;
  late final TextEditingController _senhaController;
  late final TextEditingController _confirmaSenhaController;

  // Estados reativos da interface
  bool _isLoading = false;
  bool _senhaValida = false;
  bool _telefoneValido = false;
  bool _mostrarSenha = false;
  bool _mostrarConfirmaSenha = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _telefoneController = TextEditingController();
    _senhaController = TextEditingController();
    _confirmaSenhaController = TextEditingController();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _confirmaSenhaController.dispose();
    super.dispose();
  }

  /// Conecta à API do Supabase e insere o novo registro no banco.
  ///
  /// Gerencia o estado de carregamento do botão principal e exibe feedbacks
  /// ao usuário via [SnackBar] em caso de sucesso ou erro.
  Future<void> _realizarCadastro() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      final telefoneLimpo = _telefoneController.text.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );

      await Supabase.instance.client.from('usuarios').insert({
        'nome': _nomeController.text.trim(),
        'telefone': telefoneLimpo,
        'senha': _senhaController.text, // Criptografia tratada pelo backend
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Conta criada! Aguarde a liberação do administrador.",
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao cadastrar: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Garante o encerramento do indicador de carregamento
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceXLarge,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // --- BOTÃO DE VOLTAR ---
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () => Navigator.of(context).pop(),
                              color: AppColors.textPrimary,
                              padding: const EdgeInsets.only(
                                top: AppDimensions.spaceSmall,
                                bottom: AppDimensions.spaceSmall,
                                right: AppDimensions.spaceSmall,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spaceSmall),

                          // --- CABEÇALHO DO FORMULÁRIO ---
                          const Icon(
                            AppIcons.criarContaHeader,
                            size: AppDimensions.iconSizeLarge,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: AppDimensions.spaceSmall),
                          const Text(
                            "CRIE SUA CONTA",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.overline,
                          ),
                          const SizedBox(height: AppDimensions.spaceXLarge),

                          // --- DADOS PESSOAIS ---
                          AppCardContainer(
                            titulo: "DADOS PESSOAIS",
                            icone: AppIcons.dadosPessoaisSection,
                            children: [
                              AppTextField(
                                controller: _nomeController,
                                label: 'Nome de Usuário',
                                icon: AppIcons.nome,
                                textInputAction: TextInputAction.next,
                                validator: (v) =>
                                    v!.isEmpty ? 'Informe o nome' : null,
                              ),
                              const SizedBox(height: AppDimensions.spaceLarge),
                              AppTextField(
                                controller: _telefoneController,
                                label: 'Telefone / Celular',
                                icon: AppIcons.telefone,
                                hintText: '(32) 99999-9999',
                                inputFormatters: [AppFormatters.telefone],
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                onChanged: (v) => setState(
                                  () => _telefoneValido = v.length >= 15,
                                ),
                                validator: (v) {
                                  if (v!.isEmpty) return 'Informe o telefone';
                                  if (v.length < 15)
                                    return 'Telefone incompleto';
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppDimensions.spaceSmall),
                              AppValidationIndicator(
                                isValid: _telefoneValido,
                                text: 'Mínimo de 11 dígitos',
                              ),
                            ],
                          ),

                          const SizedBox(height: AppDimensions.spaceLarge),

                          // --- SEGURANÇA ---
                          AppCardContainer(
                            titulo: "SEGURANÇA",
                            icone: AppIcons.segurancaSection,
                            children: [
                              AppTextField(
                                controller: _senhaController,
                                label: 'Senha',
                                icon: AppIcons.senha,
                                obscureText: !_mostrarSenha,
                                textInputAction: TextInputAction.next,
                                onChanged: (v) => setState(
                                  () => _senhaValida = v.length >= 8,
                                ),
                                validator: (v) => v!.length < 8
                                    ? 'Mínimo de 8 caracteres'
                                    : null,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _mostrarSenha
                                        ? AppIcons.verSenha
                                        : AppIcons.ocultarSenha,
                                    color: AppColors.textDisabled,
                                    size: AppDimensions.iconSizeMedium,
                                  ),
                                  onPressed: () => setState(
                                    () => _mostrarSenha = !_mostrarSenha,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppDimensions.spaceSmall),
                              AppValidationIndicator(
                                isValid: _senhaValida,
                                text: 'Mínimo de 8 caracteres',
                              ),
                              const SizedBox(height: AppDimensions.spaceLarge),
                              AppTextField(
                                controller: _confirmaSenhaController,
                                label: 'Confirmar Senha',
                                icon: AppIcons.confirmaSenha,
                                obscureText: !_mostrarConfirmaSenha,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _realizarCadastro(),
                                onChanged: (_) => setState(() {}),
                                validator: (v) {
                                  if (v!.isEmpty) return 'Confirme sua senha';
                                  if (v != _senhaController.text) {
                                    return 'As senhas não coincidem';
                                  }
                                  return null;
                                },
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _mostrarConfirmaSenha
                                        ? AppIcons.verSenha
                                        : AppIcons.ocultarSenha,
                                    color: AppColors.textDisabled,
                                    size: AppDimensions.iconSizeMedium,
                                  ),
                                  onPressed: () => setState(
                                    () => _mostrarConfirmaSenha =
                                        !_mostrarConfirmaSenha,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Preenche o espaço livre para empurrar os botões para o rodapé
                          const Spacer(),

                          // --- AÇÃO PRINCIPAL ---
                          ElevatedButton(
                            onPressed: _isLoading ? null : _realizarCadastro,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AppColors.textPrimary,
                                    ),
                                  )
                                : const Text('CRIAR CONTA'),
                          ),

                          const SizedBox(height: AppDimensions.spaceMedium),

                          // --- REDIRECIONAMENTO PARA LOGIN ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Já tem uma conta?",
                                style: AppTextStyles.bodyMediumSecondary,
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Faça Login"),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.spaceSmall),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
