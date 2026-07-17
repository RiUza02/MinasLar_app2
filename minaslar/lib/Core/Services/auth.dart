import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/design_system/design_system.dart';
import '../../Pages/login.dart';
import '../../Pages/a.dart';

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

  /// [Uso]: Verifica se há sessão salva e solicita biometria ou PIN do celular.
  Future<void> _verificarAcesso() async {
    try {
      // 1. Busca se existe algum usuário salvo anteriormente
      final usuarioSalvo = await _storage.read(key: 'usuario_logado');

      if (!mounted) return;

      // Se não tem ninguém salvo, manda direto para a tela de Login normal
      if (usuarioSalvo == null || usuarioSalvo.isEmpty) {
        _irParaLogin();
        return;
      }

      // 2. Verifica se o celular suporta biometria ou tem PIN cadastrado
      final podeAutenticar =
          await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();

      if (!podeAutenticar) {
        // Se o celular não tem senha nenhuma, entra direto ou manda pro login
        _irParaHome(usuarioSalvo);
        return;
      }

      // 3. Aciona a tela nativa de Digital / Face ID / PIN do celular
      final autenticado = await _localAuth.authenticate(
        localizedReason:
            'Toque no sensor ou use a senha do celular para entrar no sistema',
      );

      if (!mounted) return;

      if (autenticado) {
        _irParaHome(usuarioSalvo);
      } else {
        // Se o usuário cancelar ou errar muito, redireciona para o login manual
        _irParaLogin();
      }
    } catch (e) {
      // Em caso de qualquer erro de hardware ou storage, cai de volta no login
      if (mounted) _irParaLogin();
    }
  }

  void _irParaHome(String nome) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => TelaLogado(nomeUsuario: nome)),
      (route) => false,
    );
  }

  void _irParaLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tela de transição simples enquanto o sensor é acionado
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }
}
