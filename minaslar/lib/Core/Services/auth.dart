import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../Design/design_system.dart';
import '../../Pages/CadastroLogin/login.dart';
import '../../Pages/HomePage/home_page.dart';

// **[Propósito]** Atua como o guarda de trânsito inicial no `main.dart`, direcionando o usuário para a Home ou Login com base na sessão e biometria/PIN.
// **[Como usar]** home: const AuthGatePage() (Defina como a rota inicial da aplicação).
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

  // **[Propósito]** Executa a leitura da sessão local e dispara a checagem nativa de biometria ou senha do dispositivo.
  Future<void> _verificarAcesso() async {
    try {
      // Lê as credenciais salvas no armazenamento seguro e criptografado do dispositivo.
      final usuarioSalvo = await _storage.read(key: 'usuario_logado');
      final isAdminString = await _storage.read(key: 'is_admin');
      final isAdmin = isAdminString == 'true';

      if (!mounted) return;

      // Se não houver sessão ativa salva, redireciona imediatamente para a tela de login manual.
      if (usuarioSalvo == null || usuarioSalvo.isEmpty) {
        _irParaLogin();
        return;
      }

      // **[Uso]** Verifica se o hardware suporta e possui sensores biométricos ou senha de tela habilitados.
      final podeAutenticar =
          await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();

      // Se o dispositivo não tiver nenhuma trava de segurança nativa, libera o acesso direto.
      if (!podeAutenticar) {
        _irParaHome(usuarioSalvo, isAdmin);
        return;
      }

      // Aciona o prompt nativo do sistema operacional (FaceID, TouchID ou PIN).
      final autenticado = await _localAuth.authenticate(
        localizedReason:
            'Toque no sensor ou use a senha do celular para entrar no sistema',
      );

      if (!mounted) return;

      if (autenticado) {
        _irParaHome(usuarioSalvo, isAdmin);
      } else {
        _irParaLogin();
      }
    } catch (e) {
      // Falhas de leitura do storage ou cancelamentos de hardware encerram o fluxo direcionando para o login.
      if (mounted) _irParaLogin();
    }
  }

  // **[Propósito]** Redireciona para o painel principal, removendo todo o histórico de navegação anterior da memória.
  // **[Parâmetros]** nome (String) -> Nome do usuário recuperado do storage; isAdmin (bool) -> Define o nível de permissão da UI.
  void _irParaHome(String nome, bool isAdmin) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => HomePage(nomeUsuario: nome, isAdmin: isAdmin),
      ),
      (route) => false,
    );
  }

  // **[Propósito]** Redireciona para o login manual, substituindo a tela de carregamento atual na pilha de rotas.
  void _irParaLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Exibe um feedback visual de carregamento neutro enquanto a verificação em segundo plano ocorre.
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }
}
