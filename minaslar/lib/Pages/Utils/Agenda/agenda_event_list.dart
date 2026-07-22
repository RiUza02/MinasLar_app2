import '../../../Core/Design/design_system.dart';
import '../../../Core/Widgets/widgets.dart';
import '../../Orcamento/detalha_orcamento.dart';
import 'agenda_event_card.dart';

// **[Propósito]** Componente responsável por renderizar a lista vertical de eventos (orçamentos) agendados para um dia específico.
// **[Como usar]** Inserido na tela principal da Agenda (geralmente abaixo do calendário). Recebe a lista de dados brutos `eventos` daquele dia, a flag `isAdmin` para repassar o nível de privilégio à tela de detalhes, e uma função `onRefresh` para recarregar os dados do servidor.
class AgendaEventList extends StatelessWidget {
  final List<dynamic> eventos;
  final bool isAdmin;
  final VoidCallback onRefresh;

  const AgendaEventList({
    super.key,
    required this.eventos,
    required this.isAdmin,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppDimensions.spaceLarge,
            bottom: AppDimensions.spaceMedium,
          ),
          child: Text(
            "Orçamentos deste dia:",
            style: AppTextStyles.bodyLargeBold,
          ),
        ),

        // **[Comportamento: Tratamento de Estado Vazio]** Caso não existam orçamentos para a data focada, apresenta de forma amigável um componente visual de "lista vazia" (Empty State), prevenindo que a tela pareça estar com erro ou não carregada.
        if (eventos.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceLarge,
              vertical: AppDimensions.spaceXXLarge,
            ),
            child: AppEmptyListIndicator(
              message: "Nenhum serviço agendado.",
              icon: AppIcons.evento,
            ),
          )
        else
          // **[Comportamento: Navegação e Sincronização]** Mapeia a lista de dados para renderizar uma sequência de 'AgendaEventCard's.
          ...eventos.map(
            (item) => AgendaEventCard(
              item: item,

              // O callback de clique do card navega para a tela de Detalhes. Ao retornar (após o 'await'), aciona imediatamente o 'onRefresh()' para garantir que edições realizadas na tela filha sejam refletidas no calendário pai.
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetalhesOrcamento(
                      orcamentoInicial: item,
                      isAdmin: isAdmin,
                    ),
                  ),
                );
                onRefresh();
              },
            ),
          ),
      ],
    );
  }
}
