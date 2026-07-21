import 'package:intl/intl.dart';
import '../../../Core/Design/design_system.dart';
import '../../../Core/Widgets/widgets.dart';
import '../../../Features/Modelos/orcamento_model.dart';
import '../../Utils/ListaOrcamento/orcamento_form_controller.dart'; // <-- Importação atualizada
import 'date_selector_button.dart';
import 'time_shift_selector_button.dart';

class PrazosCard extends StatelessWidget {
  final OrcamentoFormController controller; // <-- Tipado para a classe base
  final Future<void> Function({required bool isEntrega}) onSelectDate;

  const PrazosCard({
    super.key,
    required this.controller,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    return AppCardContainer(
      icone: AppIcons.calendario,
      titulo: 'PRAZOS E HORÁRIOS',
      children: [
        Text('Preferência de Horário', style: AppTextStyles.label),
        const SizedBox(height: AppDimensions.spaceSmall),
        Row(
          children: [
            TimeShiftSelectorButton(
              texto: 'Manhã',
              icon: AppIcons.manha,
              cor: AppColors.morningShift,
              isSelected: controller.horarioSelecionado == Turno.manha,
              onTap: () => controller.setHorario(Turno.manha),
            ),
            const SizedBox(width: AppDimensions.spaceMedium),
            TimeShiftSelectorButton(
              texto: 'Tarde',
              icon: AppIcons.tarde,
              cor: AppColors.afternoonShift,
              isSelected: controller.horarioSelecionado == Turno.tarde,
              onTap: () => controller.setHorario(Turno.tarde),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spaceLarge),
        const Divider(color: AppColors.borderLight),
        const SizedBox(height: AppDimensions.spaceLarge),
        Text('Data de Entrada', style: AppTextStyles.label),
        const SizedBox(height: AppDimensions.spaceSmall),
        DateSelectorButton(
          icon: AppIcons.calendario,
          texto: DateFormat('dd/MM/yyyy').format(controller.dataPega),
          onTap: () => onSelectDate(isEntrega: false),
        ),
        const SizedBox(height: AppDimensions.spaceLarge),
        Text('Data de Entrega / Previsão', style: AppTextStyles.label),
        const SizedBox(height: AppDimensions.spaceSmall),
        Row(
          children: [
            Expanded(
              child: DateSelectorButton(
                icon: AppIcons.evento,
                texto: controller.dataEntrega != null
                    ? DateFormat('dd/MM/yyyy').format(controller.dataEntrega!)
                    : "Definir data...",
                onTap: () => onSelectDate(isEntrega: true),
              ),
            ),
            if (controller.dataEntrega != null)
              Padding(
                padding: const EdgeInsets.only(left: AppDimensions.spaceSmall),
                child: IconButton(
                  onPressed: controller.limparDataEntrega,
                  icon: const Icon(AppIcons.limpar, color: AppColors.error),
                  tooltip: "Remover data",
                ),
              ),
          ],
        ),
      ],
    );
  }
}
