import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 👇 Cole suas chaves do Supabase aqui:
  await Supabase.initialize(
    url: 'https://nnbejmzhldrwaczsntzd.supabase.co',
    publishableKey: 'sb_publishable_QPW5K917Dj_3J1Lyf3XJcw_90AlVplu',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MinasLar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.blue,
        colorScheme: const ColorScheme.dark(
          primary: Colors.blue,
          secondary: Colors.white,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white54),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          border: OutlineInputBorder(),
        ),
      ),
      // Substituímos o Roteador por uma tela inicial simples
      home: const HomePage(),
    );
  }
}

// --- TELA INICIAL LIMPA ---
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MinasLar'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'App conectado e pronto para programar!',
          style: TextStyle(fontSize: 18, color: Colors.white70),
        ),
      ),
    );
  }
}
