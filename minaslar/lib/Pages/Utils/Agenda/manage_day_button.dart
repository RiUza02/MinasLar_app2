import 'package:intl/intl.dart';
import '../../../Core/Design/design_system.dart';

// **[Propósito]** Botão de ação (Call to Action) destinado a acessar o painel de gerenciamento completo de um dia específico na agenda.
// **[Como usar]** Inserido na interface principal da Agenda, geralmente condicionado a usuários com perfil de administrador. Exige a data atualmente selecionada (`selectedDay`) e uma função de callback (`onPressed`) para acionar a navegação para a tela de edição em massa ou detalhes do dia.
class ManageDayButton extends StatelessWidget {
  final DateTime? selectedDay;
  final VoidCallback onPressed;

  const ManageDayButton({
    super.key,
    required this.selectedDay,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // **[Comportamento: Renderização Condicional]** Atua como uma barreira de segurança visual. Caso nenhuma data esteja selecionada (estado nulo), o widget retorna um `SizedBox.shrink()`, desaparecendo da interface sem ocupar espaço no layout e prevenindo erros de formatação de data ou ações em estado inválido.
    if (selectedDay == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceLarge),
      child: SizedBox(
        width: double
            .infinity, // Ocupa toda a largura disponível (full-width) para melhor ergonomia de clique.
        height: AppDimensions.buttonHeight,
        child: ElevatedButton.icon(
          // **[Comportamento: Identidade Visual Administrativa]** O botão adota a cor de destaque dedicada aos administradores (`AppColors.adminColor`), garantindo que ações gerenciais se destaquem das demais interações primárias e secundárias do usuário comum.
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.adminColor,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            ),
          ),
          onPressed: onPressed,
          icon: const Icon(Icons.list_alt),

          // **[Comportamento: Feedback de Contexto]** Utiliza a biblioteca `intl` (DateFormat) para embutir dinamicamente o dia e mês selecionados diretamente no texto do botão. Isso provê confirmação imediata ao usuário sobre qual dia exato ele está prestes a gerenciar.
          label: Text(
            "Gerenciar Dia (${DateFormat("d/MM").format(selectedDay!)})",
            style: AppTextStyles.button.copyWith(color: Colors.black),
          ),
        ),
      ),
    );
  }
}
