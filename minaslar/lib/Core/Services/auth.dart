import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../Design/design_system.dart';
import '../../Pages/CadastroLogin/login.dart';
import '../../Pages/HomePage/overview.dart';

/// **[Uso]**: Como a primeira página carregada no `main.dart`. Ela atua como o guarda de trânsito
/// inicial do app, decidindo se manda o usuário para o Login ou para a Home com base na segurança do aparelho.
class AuthGatePage extends StatefulWidget {
  const AuthGatePage({super.key});

  @override
  State<AuthGatePage> createState() => _AuthGatePageState();
}

class _AuthGatePageState extends State<AuthGatePage> {
  final _storage = const FlutterSecureStorage();
  final _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _verificarAcesso();
  }

  /// **[Uso]** Executa o fluxo de validação local da sessão e dispara a checagem de biometria ou PIN do sistema operacional.
  Future<void> _verificarAcesso() async {
    try {
      // Lê os tokens de persistência criptografados
      final usuarioSalvo = await _storage.read(key: 'usuario_logado');
      final isAdminString = await _storage.read(key: 'is_admin');
      final isAdmin = isAdminString == 'true';

      if (!mounted) return;

      // Sem sessão salva, manda direto para a tela de identificação manual
      if (usuarioSalvo == null || usuarioSalvo.isEmpty) {
        _irParaLogin();
        return;
      }

      // Valida se o smartphone possui suporte a travas de segurança ativas
      final podeAutenticar =
          await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();

      // Entra direto caso o dispositivo do usuário não possua nenhuma senha de tela configurada
      if (!podeAutenticar) {
        _irParaHome(usuarioSalvo, isAdmin);
        return;
      }

      // Abre a janela nativa do sistema (FaceID, TouchID ou PIN padrão)
      final autenticado = await _localAuth.authenticate(
        localizedReason:
            'Toque no sensor ou use a senha do celular para entrar no sistema',
      );

      if (!mounted) return;

      // Envia para a Home se passou na biometria; caso contrário, joga pro Login
      if (autenticado) {
        _irParaHome(usuarioSalvo, isAdmin);
      } else {
        _irParaLogin();
      }
    } catch (e) {
      // Qualquer falha de hardware ou erro crítico limpa o fluxo mandando para o login manual
      if (mounted) _irParaLogin();
    }
  }

  /// **[Uso]** Redireciona o usuário para o painel principal (Overview), limpando todo o histórico de rotas anterior.
  void _irParaHome(String nome, bool isAdmin) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => Overview(nomeUsuario: nome, isAdmin: isAdmin),
      ),
      (route) => false,
    );
  }

  /// **[Uso]** Substitui a tela de carregamento atual pela tela de login tradicional.
  void _irParaLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tela limpa de transição enquanto lê o storage e processa os sensores de segurança
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }
}
