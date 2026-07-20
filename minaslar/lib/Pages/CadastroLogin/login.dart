import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/Design/design_system.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/errors/errors.dart';
import 'criar_conta.dart';
import '../HomePage/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // --- CONTROLADORES DE CAMPO ---
  final _nomeController = TextEditingController();
  final _senhaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _storage = const FlutterSecureStorage();

  // --- ESTADOS DE CONTROLE DA INTERFACE ---
  bool _isLoading = false;
  bool _mostrarSenha = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  /// [Uso]: Autentica o usuário no Supabase através da função RPC.
  /// Valida o formulário, consulta o banco por nome/senha e checa a permissão de acesso.
  Future<void> _fazerLogin() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final nome = _nomeController.text.trim();
      final senha = _senhaController.text;

      // 1. Consulta RPC no banco de dados
      final List<dynamic> response = await Supabase.instance.client.rpc(
        'login_usuario',
        params: {'p_nome': nome, 'p_senha': senha},
      );

      // Verifica se a tela ainda existe antes de continuar
      if (!mounted) return;

      if (response.isEmpty) {
        throw 'Nome de usuário ou senha incorretos.';
      }

      final dadosUsuario = response.first as Map<String, dynamic>;

      if (dadosUsuario['autenticado'] == false) {
        throw 'Sua conta ainda não foi liberada por um administrador.';
      }

      // 2. Grava os dados da sessão localmente de forma criptografada
      // Garante que o ID e o telefone sejam salvos para a busca de sessão.
      await _storage.write(
        key: 'usuario_id',
        value: dadosUsuario['id']?.toString(),
      );
      await _storage.write(
        key: 'telefone',
        value: dadosUsuario['telefone']?.toString(),
      );
      await _storage.write(key: 'usuario_logado', value: dadosUsuario['nome']);
      await _storage.write(
        key: 'is_admin',
        value: dadosUsuario['is_admin'].toString(),
      );

      // Garante que o contexto ainda está ativo antes de executar a navegação.
      if (!mounted) return;

      // 3. Limpa a pilha de telas e abre a aplicação principal
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => HomePage(
            nomeUsuario: dadosUsuario['nome'],
            isAdmin: dadosUsuario['is_admin'],
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      final mensagemErro = ErrorHandler.mapearErro(e);
      _mostrarErro(mensagemErro);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// [Uso]: Exibe mensagens de feedback e alertas de erro em uma barra flutuante (SnackBar).
  void _mostrarErro(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
                              icon: const Icon(AppIcons.voltar),
                              onPressed: () => Navigator.of(context).pop(),
                              color: AppColors.textPrimary,
                              padding: const EdgeInsets.only(
                                top: AppDimensions.spaceSmall,
                                bottom: AppDimensions.spaceSmall,
                                right: AppDimensions.spaceSmall,
                              ),
                            ),
                          ),
                          // --- CABEÇALHO DA TELA ---
                          const Icon(
                            AppIcons.segurancaSection,
                            size: 84,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: AppDimensions.spaceXLarge),

                          Text(
                            "Acesso ao Sistema",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.titleLarge,
                          ),
                          const SizedBox(height: AppDimensions.spaceSmall),

                          Text(
                            "Digite suas credenciais para continuar",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMediumSecondary,
                          ),
                          const SizedBox(height: AppDimensions.spaceXXXLarge),

                          // --- FORMULÁRIO DE ENTRADA ---
                          AppCardContainer(
                            titulo: 'CREDENCIAS',
                            icone: AppIcons.segurancaSection,
                            children: [
                              AppTextField(
                                controller: _nomeController,
                                label: "Nome de usuário",
                                icon: AppIcons.nome,
                                keyboardType: TextInputType.name,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Informe o seu nome';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppDimensions.spaceLarge),
                              AppTextField(
                                controller: _senhaController,
                                label: "Senha",
                                icon: AppIcons.senha,
                                obscureText: !_mostrarSenha,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _fazerLogin(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Informe a sua senha';
                                  }
                                  return null;
                                },
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
                            ],
                          ),

                          const Spacer(),

                          // --- BOTÃO DE ACESSO ---
                          ElevatedButton(
                            onPressed: _isLoading ? null : _fazerLogin,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AppColors.textPrimary,
                                    ),
                                  )
                                : const Text("ENTRAR"),
                          ),

                          const SizedBox(height: AppDimensions.spaceMedium),

                          // --- RODAPÉ DE NAVEGAÇÃO ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Não tem uma conta?",
                                style: AppTextStyles.bodyMediumSecondary,
                              ),
                              TextButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CriarContaPage(),
                                  ),
                                ),
                                child: const Text("Cadastre-se"),
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
