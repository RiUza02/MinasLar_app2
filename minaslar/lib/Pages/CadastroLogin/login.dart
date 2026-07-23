import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/Design/design_system.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/errors/errors.dart';
import 'criar_conta.dart';
import '../HomePage/home_page.dart';

/// [Objetivo] Tela de autenticação e acesso de usuários ao sistema.
///
/// [Fluxo] Valida as credenciais localmente, executa a consulta via RPC no Supabase,
/// armazena os dados da sessão de forma criptografada e redireciona para a home.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // [Chave] Controla a validação do formulário de credenciais.
  final _formKey = GlobalKey<FormState>();

  // [Serviços] Gerencia o armazenamento seguro de tokens e dados de sessão.
  final _storage = const FlutterSecureStorage();

  // [Controladores] Gerenciam os inputs de texto.
  late final TextEditingController _nomeController;
  late final TextEditingController _senhaController;

  // [Estados Reativos] Controlam loading e visibilidade da senha.
  bool _isLoading = false;
  bool _mostrarSenha = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _senhaController = TextEditingController();
  }

  @override
  void dispose() {
    // [Descarte] Libera memória dos controladores ao destruir a tela.
    _nomeController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  /// [Objetivo] Autentica o usuário via função RPC no Supabase.
  /// [Fluxo] Valida inputs, consulta o banco, verifica permissões de administrador/liberação e persiste a sessão.
  Future<void> _fazerLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus(); // Oculta o teclado.

    try {
      final nome = _nomeController.text.trim();
      final senha = _senhaController.text;

      // [RPC] Consulta as credenciais diretamente na stored procedure do banco.
      final List<dynamic> response = await Supabase.instance.client.rpc(
        'login_usuario',
        params: {'p_nome': nome, 'p_senha': senha},
      );

      if (!mounted) return;

      if (response.isEmpty) {
        throw 'Nome de usuário ou senha incorretos.';
      }

      final dadosUsuario = response.first as Map<String, dynamic>;

      // [Validação de Acesso] Checa se o perfil já foi aprovado por um gestor.
      if (dadosUsuario['autenticado'] == false) {
        throw 'Sua conta ainda não foi liberada por um administrador.';
      }

      // [Sessão] Grava as credenciais e metadados localmente de forma criptografada.
      await Future.wait([
        _storage.write(
          key: 'usuario_id',
          value: dadosUsuario['id']?.toString(),
        ),
        _storage.write(
          key: 'telefone',
          value: dadosUsuario['telefone']?.toString(),
        ),
        _storage.write(
          key: 'usuario_logado',
          value: dadosUsuario['nome']?.toString(),
        ),
        _storage.write(
          key: 'is_admin',
          value: (dadosUsuario['is_admin'] ?? false).toString(),
        ),
      ]);

      if (!mounted) return;

      // [Navegação] Limpa a pilha de roteamento e redireciona para a aplicação principal.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => HomePage(
            nomeUsuario: dadosUsuario['nome'] ?? '',
            isAdmin: dadosUsuario['is_admin'] ?? false,
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      // [Tratamento de Erro] Mapeia a exceção e exibe feedback flutuante na UI.
      final mensagemErro = ErrorHandler.mapearErro(e);
      _mostrarErro(mensagemErro);
    } finally {
      // [Reset] Encerra o estado de carregamento.
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// [Objetivo] Exibe mensagens de feedback e alertas de erro em uma barra flutuante.
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
        // [Layout] Garante responsividade e ancoragem do rodapé sem overflow em telas menores.
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
                          // [Navegação] Retorno para a tela anterior.
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

                          // [UI] Cabeçalho visual da tela de acesso.
                          const Icon(
                            AppIcons.segurancaSection,
                            size: 84,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: AppDimensions.spaceXLarge),
                          const Text(
                            "Acesso ao Sistema",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.titleLarge,
                          ),
                          const SizedBox(height: AppDimensions.spaceSmall),
                          const Text(
                            "Digite suas credenciais para continuar",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMediumSecondary,
                          ),
                          const SizedBox(height: AppDimensions.spaceXXXLarge),

                          // [Seção] Formulário de entrada de credenciais.
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
                                // [UX] Dispara o login pela tecla 'Done' do teclado de forma fluida.
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

                          // [Espaçador] Empurra os blocos de ação para o rodapé da tela.
                          const Spacer(),

                          // [Ação Principal] Botão de submissão do login com indicador de progresso.
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

                          // [Navegação] Rota alternativa para novos usuários.
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
