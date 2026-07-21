import '../../../Core/Design/design_system.dart';
import '../../../Core/Widgets/widgets.dart';

class ServicoCard extends StatelessWidget {
  final TextEditingController tituloController;
  final TextEditingController descricaoController;

  const ServicoCard({
    super.key,
    required this.tituloController,
    required this.descricaoController,
  });

  @override
  Widget build(BuildContext context) {
    return AppCardContainer(
      icone: AppIcons.descricao,
      titulo: 'DETALHES DO SERVIÇO',
      children: [
        AppTextField(
          controller: tituloController,
          label: 'Título do Serviço',
          icon: AppIcons.titulo,
          validator: (v) => v!.isEmpty ? 'Informe um título' : null,
        ),
        const SizedBox(height: AppDimensions.spaceLarge),
        AppTextField(
          controller: descricaoController,
          label: 'Descrição (Opcional)',
          icon: AppIcons.descricao,
          maxLines: 3,
        ),
      ],
    );
  }
}
