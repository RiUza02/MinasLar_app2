import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../Core/Design/design_system.dart';
import '../../Core/Errors/errors.dart';
import '../../Core/Widgets/widgets.dart';
import '../Orcamento/detalha_orcamento.dart';
import '../Agenda/orcamentos_dia.dart';

class AgendaPage extends StatefulWidget {
  final bool isAdmin;

  const AgendaPage({super.key, this.isAdmin = false});
  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

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
    _corPrincipal = widget.isAdmin
        ? AppColors.primaryAlternative
        : AppColors.primary;
    initializeDateFormatting('pt_BR', null).then((_) {
      _carregarEventosDoMes(_focusedDay);
    });
  }

  // Lógica de Negócio
  int _compararHorarios(dynamic a, dynamic b) {
    final horarioA = (a['horario_do_dia'] ?? '').toString().toLowerCase();
    final horarioB = (b['horario_do_dia'] ?? '').toString().toLowerCase();

    if (horarioA == 'manhã' && horarioB != 'manhã') return -1;
    if (horarioB == 'manhã' && horarioA != 'manhã') return 1;
    return 0;
  }

  /// Busca no Supabase apenas os orçamentos pertencentes ao mês do [mesAlvo]
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
      ).then((_) => _carregarEventosDoMes(_focusedDay));
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

    return RefreshIndicator(
      color: _corPrincipal,
      backgroundColor: AppColors.cardBackground,
      onRefresh: () => _carregarEventosDoMes(_focusedDay),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: AppDimensions.spaceXXLarge),
        children: [
          _buildCalendar(),
          const SizedBox(height: AppDimensions.spaceXLarge),
          _buildManageDayButton(),
          const SizedBox(height: AppDimensions.spaceXLarge),
          _buildEventsList(),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      locale: 'pt_BR',
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
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
      calendarStyle: CalendarStyle(
        defaultTextStyle: const TextStyle(color: AppColors.textPrimary),
        weekendTextStyle: const TextStyle(color: AppColors.error),
        outsideTextStyle: const TextStyle(color: AppColors.textDisabled),
        selectedDecoration: BoxDecoration(
          color: _corPrincipal,
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
      // RENDERIZADOR CUSTOMIZADO DAS BOLINHAS (1 bolinha por orçamento)
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          if (events.isEmpty) return const SizedBox();

          return Positioned(
            bottom: 2,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 2.0,
              runSpacing: 1.0,
              children: List.generate(
                events.length,
                (index) => Container(
                  width: 5.0,
                  height: 5.0,
                  decoration: BoxDecoration(
                    color: _corPrincipal,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          );
        },
      ),
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
          _eventosSelecionados = _getEventosDoDia(selectedDay);
        });
      },
      onFormatChanged: (format) => setState(() => _calendarFormat = format),
      // Dispara a consulta no Supabase ao trocar de mês
      onPageChanged: (focusedDay) {
        final mesMudou =
            focusedDay.month != _focusedDay.month ||
            focusedDay.year != _focusedDay.year;

        _focusedDay = focusedDay;

        if (mesMudou) {
          _carregarEventosDoMes(focusedDay);
        }
      },
      eventLoader: _getEventosDoDia,
    );
  }

  Widget _buildManageDayButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceLarge),
      child: SizedBox(
        width: double.infinity,
        height: AppDimensions.buttonHeight,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.adminColor,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            ),
          ),
          onPressed: _navegarParaListaDoDia,
          icon: const Icon(Icons.list_alt),
          label: Text(
            "Gerenciar Dia (${DateFormat("d/MM").format(_selectedDay!)})",
            style: AppTextStyles.button.copyWith(color: Colors.black),
          ),
        ),
      ),
    );
  }

  Widget _buildEventsList() {
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
        if (_eventosSelecionados.isEmpty)
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
          ..._eventosSelecionados.map((item) => _buildEventCard(item)),
      ],
    );
  }

  Widget _buildEventCard(Map<String, dynamic> item) {
    final titulo = item['titulo'] ?? 'Sem Título';
    final clienteData = item['clientes'];
    final nomeCliente = clienteData?['nome'] ?? 'Cliente não identificado';
    final bairroCliente = clienteData?['bairro'] ?? '';
    final horario = item['horario_do_dia'] ?? 'Manhã';
    final isTarde = horario.toString().toLowerCase() == 'tarde';

    final iconHorario = isTarde ? AppIcons.tarde : AppIcons.manha;
    final colorHorario = isTarde
        ? AppColors.afternoonShift
        : AppColors.morningShift;

    return Card(
      color: AppColors.cardBackground,
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceLarge,
        vertical: AppDimensions.spaceSmall,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceLarge,
          vertical: AppDimensions.spaceMedium,
        ),
        leading: Container(
          padding: const EdgeInsets.all(AppDimensions.spaceSmall),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          child: Icon(iconHorario, color: colorHorario, size: 24),
        ),
        title: Text(titulo, style: AppTextStyles.bodyMediumBold),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppDimensions.spaceXSmall),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    AppIcons.cliente,
                    size: AppDimensions.iconSizeXSmall,
                    color: AppColors.textDisabled,
                  ),
                  const SizedBox(width: AppDimensions.spaceXSmall),
                  Expanded(
                    child: Text(
                      nomeCliente,
                      style: AppTextStyles.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spaceSmall),
              Row(
                children: [
                  const Icon(
                    AppIcons.bairro,
                    size: AppDimensions.iconSizeXSmall,
                    color: AppColors.textDisabled,
                  ),
                  const SizedBox(width: AppDimensions.spaceXSmall),
                  Expanded(
                    child: Text(
                      bairroCliente,
                      style: AppTextStyles.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceSmall,
            vertical: AppDimensions.spaceXSmall,
          ),
          decoration: BoxDecoration(
            color: colorHorario.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            border: Border.all(color: colorHorario.withValues(alpha: 0.5)),
          ),
          child: Text(
            horario.toUpperCase(),
            style: AppTextStyles.caption.copyWith(
              color: colorHorario,
              fontSize: 10,
            ),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalhesOrcamento(
                orcamentoInicial: item,
                isAdmin: widget.isAdmin,
              ),
            ),
          ).then((_) => _carregarEventosDoMes(_focusedDay));
        },
      ),
    );
  }
}
