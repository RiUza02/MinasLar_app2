import '../../../../Core/Design/design_system.dart';

/// [uso] Exibe um diálogo para importar os dados de um cliente
/// a partir de um texto colado pelo usuário.
class ClienteImportDialog extends StatefulWidget {
  const ClienteImportDialog({super.key});

  @override
  State<ClienteImportDialog> createState() => _ClienteImportDialogState();
}

class _ClienteImportDialogState extends State<ClienteImportDialog> {
  /// Controla o campo onde o texto é colado.
  final _importController = TextEditingController();

  @override
  void dispose() {
    // Libera os recursos do controller.
    _importController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // Aparência do diálogo.
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),

      // Título.
      title: const Row(
        children: [
          Icon(Icons.paste, color: AppColors.primaryAlternative),
          SizedBox(width: AppDimensions.spaceSmall),
          Text("Importar Dados"),
        ],
      ),
      titleTextStyle: AppTextStyles.titleMedium,

      // Conteúdo do diálogo.
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instruções para importação.
            Text(
              "Cole o texto abaixo na seguinte ordem:\n1. Nome\n2. Telefone\n3. Rua\n4. Número\n5. Bairro",
              style: AppTextStyles.bodyMediumSecondary.copyWith(fontSize: 13),
            ),
            const SizedBox(height: AppDimensions.spaceMedium),

            // Campo para colar os dados.
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

      // Botões de ação.
      actions: [
        // Fecha o diálogo sem importar.
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),

        // Retorna o texto informado.
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
