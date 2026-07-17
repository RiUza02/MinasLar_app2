import 'package:flutter/material.dart';
import '../core/design_system/design_system.dart';
import 'cadastro_login/criarconta.dart';
import 'cadastro_login/login.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spaceLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Empurra a imagem para baixo, alinhando-a no meio
              const Spacer(),

              // Imagem de ponta a ponta horizontalmente, mas centralizada verticalmente
              Image.asset(
                'lib/Core/Design_System/Assets/logo.jpg',
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),

              // Empurra os botões para o fundo e equilibra a imagem no centro
              const Spacer(),

              // BOTÃO: CRIAR CONTA (Mantém a cor principal azul do tema)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CriarContaPage(),
                      ),
                    );
                  },
                  child: const Text('Criar Conta'),
                ),
              ),

              // Espaçamento padronizado entre os dois botões
              const SizedBox(height: AppDimensions.spaceMedium),

              // BOTÃO: FAZER LOGIN (Usa o novo botão cinza secundário)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: AppTheme.secondaryButton,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  child: const Text('Fazer Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
