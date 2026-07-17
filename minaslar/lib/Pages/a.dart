import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'telainicial.dart';

class TelaLogado extends StatelessWidget {
  final String nomeUsuario;

  const TelaLogado({super.key, required this.nomeUsuario});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: tema.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 80,
                  color: tema.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),

              Text(
                "Sessão Iniciada!",
                style: tema.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                "Você está logado no sistema como:",
                style: tema.textTheme.bodyLarge?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),

              Text(
                nomeUsuario,
                style: tema.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: tema.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 48),

              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(180, 48),
                  side: BorderSide(color: tema.colorScheme.error),
                  foregroundColor: tema.colorScheme.error,
                ),
                onPressed: () async {
                  // Limpa a sessão do usuário salva no dispositivo
                  await const FlutterSecureStorage().delete(
                    key: 'usuario_logado',
                  );

                  if (!context.mounted) return;

                  // Volta para a tela inicial, limpando o histórico de navegação
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomePage()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout, size: 20),
                label: const Text(
                  "SAIR DO SISTEMA",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
