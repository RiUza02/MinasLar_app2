import 'package:flutter/material.dart';
import '../../../core/Design/design_system.dart';
import 'criar_conta.dart';
import '../../core/services/auth.dart';

/// [Objetivo] Tela inicial de boas-vindas (Landing/Welcome Page) que atua como porta de entrada.
///
/// [Fluxo] Apresenta a identidade visual da aplicação e direciona o usuário para o fluxo
/// de novo cadastro (Criar Conta) ou para o fluxo de autenticação (Login/AuthGate).
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        // [Layout] Garante respeito às margens de segurança do dispositivo (notch, barra de navegação).
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spaceLarge),
          child: Column(
            // [UX/UI] O 'stretch' força todos os filhos (como os botões) a ocuparem a largura total da tela.
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // [Espaçador] Empurra o logo para baixo, equilibrando a centralização vertical.
              const Spacer(),

              // [UI] Logo da aplicação ajustado horizontalmente de ponta a ponta.
              Image.asset(
                'lib/Core/Design_System/Assets/logo.jpg',
                fit: BoxFit.fitWidth,
              ),

              // [Espaçador] Empurra o bloco de ações para a base da tela.
              const Spacer(),

              // [Ação Primária] Direciona para a tela de registro de novos usuários.
              ElevatedButton(
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

              // [UI] Espaçamento vertical padronizado entre elementos de ação.
              const SizedBox(height: AppDimensions.spaceMedium),

              // [Ação Secundária] Direciona para o portão de autenticação (Login / Checagem de Sessão).
              ElevatedButton(
                style: AppTheme.secondaryButton,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AuthGatePage(),
                    ),
                  );
                },
                child: const Text('Fazer Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
