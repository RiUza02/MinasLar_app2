import '../../../../Core/Design/design_system.dart';
import '../../../../Core/Utils/formatters.dart';
import '../../../Features/Modelos/cliente_model.dart';

// **[Propósito]** Enumeração que define as ações e escolhas disponíveis para o usuário ao lidar com o alerta de um cliente duplicado.
enum ClienteDuplicadoAction { cancelar, criarMesmoAssim, criarOrcamento }

// **[Propósito]** Componente visual de alerta (Dialog) exibido para notificar o usuário sobre a existência de um cliente com dados semelhantes (nome e endereço), oferecendo alternativas para resolver o conflito (cancelar, duplicar ou reaproveitar).
// **[Como usar]** final acao = await showDialog<ClienteDuplicadoAction>(context: context, builder: (_) => ClienteDuplicadoDialog(clienteEncontrado: clienteAtual));
class ClienteDuplicadoDialog extends StatelessWidget {
  final Cliente clienteEncontrado;

  // **[Propósito]** Constrói o diálogo exigindo a injeção da instância do cliente que foi previamente encontrado no banco de dados com similaridade.
  const ClienteDuplicadoDialog({super.key, required this.clienteEncontrado});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      title: const Row(
        children: [
          Icon(AppIcons.clientes, color: AppColors.warning),
          SizedBox(width: AppDimensions.spaceSmall),
          Text("Cliente Parecido Encontrado"),
        ],
      ),
      titleTextStyle: AppTextStyles.titleMedium,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Encontramos um cliente com nome e endereço semelhantes:",
              style: AppTextStyles.bodyMediumSecondary,
            ),
            const SizedBox(height: AppDimensions.spaceLarge),

            Container(
              padding: const EdgeInsets.all(AppDimensions.spaceMedium),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    clienteEncontrado.nome,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceXSmall),
                  Text(
                    "${clienteEncontrado.rua}, ${clienteEncontrado.numero} - ${clienteEncontrado.bairro}",
                    style: AppTextStyles.bodyMediumSecondary,
                  ),
                  const SizedBox(height: AppDimensions.spaceXSmall),
                  Text(
                    AppFormatters.telefone.maskText(clienteEncontrado.telefone),
                    style: AppTextStyles.bodyMediumSecondary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.spaceLarge),
            Text(
              "O que você deseja fazer?",
              style: AppTextStyles.bodyMediumSecondary,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context, ClienteDuplicadoAction.cancelar),
          child: const Text("Cancelar"),
        ),
        OutlinedButton(
          onPressed: () =>
              Navigator.pop(context, ClienteDuplicadoAction.criarMesmoAssim),
          child: const Text("Criar Mesmo Assim"),
        ),
        ElevatedButton.icon(
          onPressed: () =>
              Navigator.pop(context, ClienteDuplicadoAction.criarOrcamento),
          icon: const Icon(AppIcons.adicionarOrcamento),
          label: const Text("Criar Orçamento"),
        ),
      ],
    );
  }
}
