import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/design_system/design_system.dart';
import 'Pages/a.dart';
import 'Pages/telainicial.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialização do Supabase
  await Supabase.initialize(
    url: 'https://nnbejmzhldrwaczsntzd.supabase.co',
    publishableKey: 'sb_publishable_QPW5K917Dj_3J1Lyf3XJcw_90AlVplu',
  );

  runApp(const MyApp());
}

// Inicialização do aplicativo
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MinasLar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: FutureBuilder<String?>(
        future: const FlutterSecureStorage().read(key: 'usuario_logado'),
        builder: (context, snapshot) {
          // Enquanto aguarda a leitura, exibe uma tela de carregamento.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }

          // Se houver um usuário salvo e não estiver vazio, vá para a tela de logado.
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data!.isNotEmpty) {
            return TelaLogado(nomeUsuario: snapshot.data!);
          }

          // Caso contrário, vá para a tela inicial pública.
          return const HomePage();
        },
      ),
    );
  }
}
