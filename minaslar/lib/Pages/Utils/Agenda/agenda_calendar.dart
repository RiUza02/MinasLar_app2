import 'package:table_calendar/table_calendar.dart';
import '../../../Core/Design/design_system.dart';

// **[Propósito]** Componente visual reutilizável de calendário, abstraído sobre o pacote `table_calendar`. Fornece a interface para navegação entre meses e seleção de datas, além de exibir a densidade de eventos (orçamentos) por dia.
// **[Como usar]** Inserido dentro da `AgendaPage`. Requer o estado atual da data focada/selecionada, callbacks para sincronizar a navegação com o componente pai, uma função `eventLoader` para carregar as marcações de eventos de cada dia, e a cor principal baseada no perfil de acesso.
class AgendaCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final CalendarFormat calendarFormat;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;
  final Function(CalendarFormat) onFormatChanged;
  final List<dynamic> Function(DateTime) eventLoader;
  final Color corPrincipal;

  const AgendaCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.calendarFormat,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.onFormatChanged,
    required this.eventLoader,
    required this.corPrincipal,
  });

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      locale: 'pt_BR',
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: focusedDay,
      calendarFormat: calendarFormat,

      // **[Comportamento: Restrição de Interface]** O cabeçalho foi configurado para ocultar o botão de mudança de formato (mês/quinzena/semana) definindo `formatButtonVisible: false`, forçando a visualização projetada no pai.
      headerStyle: HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        titleTextStyle: AppTextStyles.titleMedium,
        leftChevronIcon: const Icon(
          Icons.chevron_left,
          color: AppColors.textPrimary,
        ),
        rightChevronIcon: const Icon(
          Icons.chevron_right,
          color: AppColors.textPrimary,
        ),
      ),

      // **[Subcomponente: Estilização do Calendário]** Define a paleta de cores para estados diferentes dos dias: dias úteis normais, finais de semana destacados em tom de erro/alerta, e dias fora do mês atual com cor esmaecida.
      calendarStyle: CalendarStyle(
        defaultTextStyle: const TextStyle(color: AppColors.textPrimary),
        weekendTextStyle: const TextStyle(color: AppColors.error),
        outsideTextStyle: const TextStyle(color: AppColors.textDisabled),

        // **[Comportamento: Feedback Visual]** O dia atualmente selecionado recebe um fundo preenchido na cor principal. O dia "de hoje" cronológico recebe apenas uma borda demarcada (vazada) para se manter em evidência sem competir com a data selecionada.
        selectedDecoration: BoxDecoration(
          color: corPrincipal,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.adminColor, width: 2.0),
        ),
        todayTextStyle: AppTextStyles.bodyMediumBold.copyWith(
          color: AppColors.adminColor,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        // **[Comportamento: Indicadores de Densidade]** Sobrescreve a renderização de marcadores (`markerBuilder`). Ao invés de listar tudo, exibe pontos na parte inferior da célula de data, limitados ao máximo de 4 por dia, proporcionando uma noção de volume (quantidade de compromissos) sem poluir o layout visual do calendário.
        markerBuilder: (context, day, events) {
          if (events.isEmpty) return const SizedBox();

          return Positioned(
            bottom: 2,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 2.0,
              runSpacing: 1.0,
              children: List.generate(
                events.length > 4 ? 4 : events.length,
                (index) => Container(
                  width: 5.0,
                  height: 5.0,
                  decoration: BoxDecoration(
                    color: corPrincipal,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          );
        },
      ),
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      onDaySelected: onDaySelected,
      onPageChanged: onPageChanged,
      onFormatChanged: onFormatChanged,
      eventLoader: eventLoader,
    );
  }
}
