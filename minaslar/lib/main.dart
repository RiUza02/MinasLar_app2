import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/design_system/design_system.dart';
import 'core/services/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicialização do Supabase
    await Supabase.initialize(
      url: 'https://nnbejmzhldrwaczsntzd.supabase.co',
      publishableKey: 'sb_publishable_QPW5K917Dj_3J1Lyf3XJcw_90AlVplu',
    );
  } catch (e) {
    debugPrint('Erro ao inicializar o Supabase: $e');
  }

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
      home: const AuthGatePage(),
    );
  }
}
