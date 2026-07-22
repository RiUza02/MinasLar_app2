import '../../../../Core/Design/design_system.dart';

// **[Propósito]** Componente visual de alerta (Dialog) interativo que permite ao usuário colar blocos de texto contendo dados brutos de um cliente (como mensagens de WhatsApp) para posterior extração e preenchimento automático.
// **[Como usar]** final textoImportado = await showDialog<String>(context: context, builder: (_) => const ClienteImportDialog());
class ClienteImportDialog extends StatefulWidget {
  const ClienteImportDialog({super.key});

  @override
  State<ClienteImportDialog> createState() => _ClienteImportDialogState();
}

class _ClienteImportDialogState extends State<ClienteImportDialog> {
  final _importController = TextEditingController();

  @override
  void dispose() {
    _importController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      title: const Row(
        children: [
          Icon(AppIcons.importar, color: AppColors.primaryAlternative),
          SizedBox(width: AppDimensions.spaceSmall),
          Text("Importar Dados"),
        ],
      ),
      titleTextStyle: AppTextStyles.titleMedium,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Cole o texto abaixo na seguinte ordem:\n1. Nome\n2. Telefone\n3. Rua\n4. Número\n5. Bairro",
              style: AppTextStyles.bodyMediumSecondary.copyWith(fontSize: 13),
            ),
            const SizedBox(height: AppDimensions.spaceMedium),
            TextField(
              controller: _importController,
              maxLines: 8,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: "Cole o texto aqui...",
                filled: true,
                fillColor: AppColors.inputBackground,
                hintStyle: AppTextStyles.inputHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMedium,
                  ),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, _importController.text);
          },
          child: const Text("Preencher Campos"),
        ),
      ],
    );
  }
}
