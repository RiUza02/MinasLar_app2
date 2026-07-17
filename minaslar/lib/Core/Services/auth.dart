import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/design_system/design_system.dart';
import '../../Pages/login.dart';
import '../../Pages/homepage.dart';

/// Tela de roteamento inicial que valida a sessão local e exige biometria/PIN.
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

  /// Valida a sessão criptografada e aciona a segurança nativa do aparelho.
  Future<void> _verificarAcesso() async {
    try {
      // 1. Lê os dados de sessão salvos localmente
      final usuarioSalvo = await _storage.read(key: 'usuario_logado');
      final isAdminString = await _storage.read(key: 'is_admin');
      final isAdmin = isAdminString == 'true';

      if (!mounted) return;

      // Sem sessão ativa, redireciona para o login manual
      if (usuarioSalvo == null || usuarioSalvo.isEmpty) {
        _irParaLogin();
        return;
      }

      // 2. Verifica se o aparelho possui biometria ou PIN cadastrados
      final podeAutenticar =
          await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();

      // Se o aparelho não tem senha de tela, entra direto na sessão salva
      if (!podeAutenticar) {
        _irParaHome(usuarioSalvo, isAdmin);
        return;
      }

      // 3. Aciona o sensor nativo (Digital, Face ID ou PIN)
      final autenticado = await _localAuth.authenticate(
        localizedReason:
            'Toque no sensor ou use a senha do celular para entrar no sistema',
      );

      if (!mounted) return;

      // Redireciona conforme o resultado da leitura biométrica
      if (autenticado) {
        _irParaHome(usuarioSalvo, isAdmin);
      } else {
        _irParaLogin();
      }
    } catch (e) {
      // Em caso de erro nativo ou falha de hardware, reinicia pelo login
      if (mounted) _irParaLogin();
    }
  }

  /// Limpa o histórico de navegação e abre a HomePage.
  void _irParaHome(String nome, bool isAdmin) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => Overview(nomeUsuario: nome, isAdmin: isAdmin),
      ),
      (route) => false,
    );
  }

  /// Substitui a tela atual pela LoginPage.
  void _irParaLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Exibe indicador de carregamento durante a leitura e autenticação
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }
}
