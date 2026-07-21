import '../../../../Core/Design/design_system.dart';
import '../../../../Core/Utils/formatters.dart';
import '../../../Features/Modelos/cliente_model.dart';

/// [uso] Define as ações disponíveis no diálogo de cliente duplicado.
enum ClienteDuplicadoAction { cancelar, criarMesmoAssim, criarOrcamento }

/// [uso] Exibe um diálogo quando um cliente semelhante é encontrado,
/// permitindo cancelar, criar um novo cliente ou criar um orçamento
/// para o cliente existente.
class ClienteDuplicadoDialog extends StatelessWidget {
  /// Cliente encontrado com dados semelhantes.
  final Cliente clienteEncontrado;

  const ClienteDuplicadoDialog({super.key, required this.clienteEncontrado});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // Cor de fundo do diálogo.
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),

      // Título do diálogo.
      title: const Row(
        children: [
          Icon(AppIcons.clientes, color: Colors.amber),
          SizedBox(width: AppDimensions.spaceSmall),
          Text("Cliente Parecido Encontrado"),
        ],
      ),
      titleTextStyle: AppTextStyles.titleMedium,

      // Conteúdo principal.
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

            // Exibe os dados do cliente encontrado.
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
                  // Nome do cliente.
                  Text(
                    clienteEncontrado.nome,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceXSmall),

                  // Endereço resumido.
                  Text(
                    "${clienteEncontrado.rua}, ${clienteEncontrado.numero} - ${clienteEncontrado.bairro}",
                    style: AppTextStyles.bodyMediumSecondary,
                  ),
                  const SizedBox(height: AppDimensions.spaceXSmall),

                  // Telefone formatado.
                  Text(
                    AppFormatters.telefone.maskText(clienteEncontrado.telefone),
                    style: AppTextStyles.bodyMediumSecondary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.spaceLarge),

            // Pergunta ao usuário qual ação deseja realizar.
            Text(
              "O que você deseja fazer?",
              style: AppTextStyles.bodyMediumSecondary,
            ),
          ],
        ),
      ),

      // Botões de ação.
      actions: [
        // Fecha o diálogo sem continuar.
        TextButton(
          onPressed: () =>
              Navigator.pop(context, ClienteDuplicadoAction.cancelar),
          child: const Text("Cancelar"),
        ),

        // Cria um novo cliente mesmo havendo um semelhante.
        OutlinedButton(
          onPressed: () =>
              Navigator.pop(context, ClienteDuplicadoAction.criarMesmoAssim),
          child: const Text("Criar Mesmo Assim"),
        ),

        // Cria um orçamento para o cliente encontrado.
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
