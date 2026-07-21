import '../../../Core/Design/design_system.dart';
import '../../../Core/Widgets/widgets.dart';

class FinanceiroCard extends StatelessWidget {
  final TextEditingController valorController;

  const FinanceiroCard({super.key, required this.valorController});

  @override
  Widget build(BuildContext context) {
    return AppCardContainer(
      icone: AppIcons.valor,
      titulo: 'FINANCEIRO',
      children: [
        AppTextField(
          controller: valorController,
          label: 'Valor (R\$) - Opcional',
          icon: AppIcons.valor,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ],
    );
  }
}
