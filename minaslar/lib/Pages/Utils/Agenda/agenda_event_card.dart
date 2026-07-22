import '../../../Core/Design/design_system.dart';

// **[Propósito]** Componente visual de card que exibe as informações resumidas de um evento/orçamento específico na agenda diária.
// **[Como usar]** Utilizado dentro de listas de exibição de agendamentos (como na `AgendaEventList`). Requer um mapa de dados (`item`) contendo as informações do banco de dados (Supabase) e uma função de callback (`onTap`) para interações, como abrir os detalhes ou iniciar a edição do evento.
class AgendaEventCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const AgendaEventCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // **[Comportamento: Tratamento de Dados Nulos]** Realiza a leitura defensiva dos dados do dicionário, provendo valores padrão (fallback) para evitar quebras de interface caso as informações venham incompletas do banco.
    final titulo = item['titulo'] ?? 'Sem Título';
    final clienteData = item['clientes'];
    final nomeCliente = clienteData?['nome'] ?? 'Cliente não identificado';
    final bairroCliente = clienteData?['bairro'] ?? '';
    final horario = item['horario_do_dia'] ?? 'Manhã';

    // **[Comportamento: Identidade Visual por Turno]** Avalia o período do evento para definir dinamicamente a iconografia e a paleta de cores (manhã x tarde) que estilizarão os elementos gráficos do card.
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
              _buildInfoRow(AppIcons.cliente, nomeCliente),
              const SizedBox(height: AppDimensions.spaceSmall),
              _buildInfoRow(AppIcons.bairro, bairroCliente),
            ],
          ),
        ),
        trailing: _buildHorarioTag(horario, colorHorario),
        onTap: onTap,
      ),
    );
  }

  // **[Subcomponente: Linha de Metadados]** Padroniza a renderização visual de informações secundárias (como nome do cliente e localização), alinhando um ícone descritivo ao texto. Aplica 'TextOverflow.ellipsis' para prevenir quebra de layout em nomes muito extensos.
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: AppDimensions.iconSizeXSmall,
          color: AppColors.textDisabled,
        ),
        const SizedBox(width: AppDimensions.spaceXSmall),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // **[Subcomponente: Badge de Turno]** Constrói um marcador (tag) fixado na extremidade direita do card. Utiliza a cor do turno com um fundo translúcido para criar contraste sem sobrecarregar a interface.
  Widget _buildHorarioTag(String horario, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceSmall,
        vertical: AppDimensions.spaceXSmall,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        horario.toUpperCase(),
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
