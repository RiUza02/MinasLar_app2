import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../Core/Design/design_system.dart';
import '../../Core/Errors/errors.dart';
import '../../Core/Widgets/widgets.dart';
import '../Agenda/orcamentos_dia.dart';
import '../Utils/Agenda/agenda_calendar.dart';
import '../Utils/Agenda/agenda_event_list.dart';
import '../Utils/Agenda/manage_day_button.dart';

// **[Propósito]** Tela principal de gerenciamento de Agenda. Exibe um calendário interativo que permite visualizar e gerenciar orçamentos/compromissos agendados. Otimizada para buscar dados por blocos mensais no backend.
// **[Como usar]** Geralmente inserida como uma das abas principais do aplicativo (ex: via BottomNavigationBar). Recebe a flag `isAdmin` para adaptar o layout (como a cor de destaque) e possivelmente os níveis de acesso a funcionalidades de edição nos subcomponentes.
class AgendaPage extends StatefulWidget {
  final bool isAdmin;

  const AgendaPage({super.key, this.isAdmin = false});
  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

// **[Comportamento: Retenção de Estado]** Implementa `AutomaticKeepAliveClientMixin` para garantir que o mês visualizado e a data selecionada não sejam resetados quando o usuário navegar para outras abas do aplicativo e voltar.
class _AgendaPageState extends State<AgendaPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Estado e Configurações
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<dynamic>> _eventosPorDia = {};
  List<dynamic> _eventosSelecionados = [];
  bool _isLoading = true;
  String? _error;
  late Color _corPrincipal;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // **[Comportamento: Identidade Visual]** Define a cor de destaque baseada no perfil de acesso (Admin vs Operacional).
    _corPrincipal = widget.isAdmin
        ? AppColors.primaryAlternative
        : AppColors.primary;
    initializeDateFormatting('pt_BR', null).then((_) {
      _carregarEventosDoMes(_focusedDay);
    });
  }

  // Lógica de Negócio
  // **[Comportamento: Ordenação]** Garante que os compromissos marcados para o período da "manhã" apareçam primeiro nas listagens diárias.
  int _compararHorarios(dynamic a, dynamic b) {
    final horarioA = (a['horario_do_dia'] ?? '').toString().toLowerCase();
    final horarioB = (b['horario_do_dia'] ?? '').toString().toLowerCase();

    if (horarioA == 'manhã' && horarioB != 'manhã') return -1;
    if (horarioB == 'manhã' && horarioA != 'manhã') return 1;
    return 0;
  }

  /// Busca no Supabase apenas os orçamentos pertencentes ao mês do [mesAlvo]
  // **[Comportamento: Otimização de Rede]** Realiza o fetch em "lote" por mês. Isso evita múltiplas consultas ao banco de dados sempre que o usuário clica em um dia diferente.
  Future<void> _carregarEventosDoMes([DateTime? mesAlvo]) async {
    if (!mounted) return;

    final dataReferencia = mesAlvo ?? _focusedDay;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Define primeiro e último dia/horário do mês selecionado
      final inicioMes = DateTime(dataReferencia.year, dataReferencia.month, 1);
      final fimMes = DateTime(
        dataReferencia.year,
        dataReferencia.month + 1,
        0,
        23,
        59,
        59,
      );

      final response = await Supabase.instance.client
          .from('orcamentos')
          .select(
            'id, data_pega, titulo, horario_do_dia, clientes!cliente_id(nome, bairro)',
          )
          .gte('data_pega', inicioMes.toIso8601String())
          .lte('data_pega', fimMes.toIso8601String());

      final List<dynamic> dados = response;
      final Map<DateTime, List<dynamic>> eventos = {};

      // **[Comportamento: Normalização de Dados]** Mapeia a lista linear recebida do backend agrupando-os pelas datas exatas (zerando horas e minutos) para compatibilidade perfeita com o TableCalendar.
      for (var item in dados) {
        if (item['data_pega'] != null) {
          final dataOriginal = DateTime.tryParse(item['data_pega'] as String);

          if (dataOriginal != null) {
            final dataNormalizada = DateTime(
              dataOriginal.year,
              dataOriginal.month,
              dataOriginal.day,
            );

            eventos.putIfAbsent(dataNormalizada, () => []).add(item);
          }
        }
      }

      eventos.forEach((key, lista) => lista.sort(_compararHorarios));

      if (mounted) {
        setState(() {
          _eventosPorDia = eventos;
          _eventosSelecionados = _getEventosDoDia(
            _selectedDay ?? DateTime.now(),
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("ERRO REAL NA AGENDA: $e");

      if (mounted) {
        setState(() {
          _error = ErrorHandler.mapearErro(e);
          _isLoading = false;
        });
      }
    }
  }

  void _handleDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _eventosSelecionados = _getEventosDoDia(selectedDay);
      });
    }
  }

  // **[Comportamento: Paginação Inteligente]** Só dispara um novo carregamento de dados do servidor se a visualização do calendário navegar efetivamente para um novo mês/ano.
  void _handlePageChange(DateTime focusedDay) {
    final mesMudou =
        focusedDay.month != _focusedDay.month ||
        focusedDay.year != _focusedDay.year;

    // Atualiza o foco visual do calendário imediatamente
    setState(() {
      _focusedDay = focusedDay;
    });

    // Carrega os dados apenas se o mês for diferente
    if (mesMudou) {
      _carregarEventosDoMes(focusedDay);
    }
  }

  void _handleFormatChange(CalendarFormat format) {
    if (_calendarFormat != format) {
      setState(() {
        _calendarFormat = format;
      });
    }
  }

  List<dynamic> _getEventosDoDia(DateTime dia) {
    final dataNormalizada = DateTime(dia.year, dia.month, dia.day);
    final eventos = _eventosPorDia[dataNormalizada] ?? [];
    eventos.sort(_compararHorarios);
    return eventos;
  }

  void _navegarParaListaDoDia() {
    if (_selectedDay != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrcamentosDia(
            dataSelecionada: _selectedDay!,
            isAdmin: widget.isAdmin,
          ),
        ),
      ).then(
        (_) => _carregarEventosDoMes(_focusedDay),
      ); // Recarrega os dados ao retornar para refletir possíveis edições
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(backgroundColor: AppColors.background, body: _buildBody());
  }

  Widget _buildBody() {
    if (_isLoading && _eventosPorDia.isEmpty) {
      return Center(child: CircularProgressIndicator(color: _corPrincipal));
    }

    if (_error != null) {
      return AppErrorView(
        message: _error!,
        onTryAgain: () => _carregarEventosDoMes(_focusedDay),
        buttonText: "Tentar Novamente",
      );
    }

    // **[Subcomponente: Estrutura Principal]** Combina "Pull-to-refresh" na página inteira e empilha 3 componentes fundamentais da visão de agenda: O calendário interativo, um botão para a gestão do dia e uma lista rápida dos eventos.
    return RefreshIndicator(
      color: _corPrincipal,
      backgroundColor: AppColors.cardBackground,
      onRefresh: () => _carregarEventosDoMes(_focusedDay),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: AppDimensions.spaceXXLarge),
        children: [
          AgendaCalendar(
            focusedDay: _focusedDay,
            selectedDay: _selectedDay,
            calendarFormat: _calendarFormat,
            onDaySelected: _handleDaySelected,
            onPageChanged: _handlePageChange,
            onFormatChanged: _handleFormatChange,
            eventLoader: _getEventosDoDia,
            corPrincipal: _corPrincipal,
          ),
          const SizedBox(height: AppDimensions.spaceXLarge),
          ManageDayButton(
            selectedDay: _selectedDay,
            onPressed: _navegarParaListaDoDia,
          ),
          const SizedBox(height: AppDimensions.spaceXLarge),
          AgendaEventList(
            eventos: _eventosSelecionados,
            isAdmin: widget.isAdmin,
            onRefresh: () => _carregarEventosDoMes(_focusedDay),
          ),
        ],
      ),
    );
  }
}
