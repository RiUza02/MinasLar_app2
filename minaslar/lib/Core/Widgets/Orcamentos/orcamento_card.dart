import '../../../Core/Design/design_system.dart';
import '../../../Core/Services/communication.dart';
import '../../Design/borders.dart';
import '../widgets.dart';

/// [uso] Card para exibição de um orçamento na HomePage com destaque para Urgências.
class OrcamentoCard extends StatelessWidget {
  final Map<String, dynamic> orcamento;
  final VoidCallback onCardTap;

  const OrcamentoCard({
    super.key,
    required this.orcamento,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    // Extração e tratamento preventivo de dados nulos da API.
    final cliente = orcamento['clientes'] ?? {};
    final nomeCliente = cliente['nome'] ?? 'Cliente';
    final telefone = cliente['telefone'] ?? '';
    final rua = cliente['rua'] ?? '';
    final numero = cliente['numero'] ?? 'S/N';
    final apartamento = cliente['apartamento'] ?? '';
    final bairro = cliente['bairro'] ?? '';
    final tituloServico = orcamento['titulo'] ?? '';

    // Como a coluna eh_urgente é BOOLEAN NOT NULL no Postgres, extraímos direto com fallback seguro.
    final bool isUrgente = orcamento['eh_urgente'] == true;

    final horarioTexto = (orcamento['horario_do_dia'] ?? 'Manhã').toString();
    final isTarde = horarioTexto.toLowerCase() == 'tarde';

    // Define a identidade visual e as bordas decorativas baseadas no nível de prioridade (Urgente > Turno).
    final Color corDestaque;
    final Border cardBorder;

    if (isUrgente) {
      corDestaque = AppColors.error;
      cardBorder = AppBorders.urgent;
    } else if (isTarde) {
      corDestaque = AppColors.afternoonShift;
      cardBorder = AppBorders.afternoonShift;
    } else {
      corDestaque = AppColors.morningShift;
      cardBorder = AppBorders.morningShift;
    }

    // A cor da tag de turno permanece estrita ao horário, sem herdar a cor de urgência.
    final Color corTurno = isTarde
        ? AppColors.afternoonShift
        : AppColors.morningShift;
    final IconData iconHorario = isTarde
        ? Icons.wb_twilight
        : Icons.wb_sunny_outlined;
    final String labelTurno = isTarde ? "TARDE" : "MANHÃ";

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceLarge),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: cardBorder,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onCardTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Linha lateral decorativa que reflete visualmente a prioridade definida.
              Container(
                width: AppDimensions.spaceSmall,
                color: corDestaque.withAlpha((255 * 0.15).round()),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.spaceLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Ícone e identificador do Turno (Manhã ou Tarde)
                          _buildTurnoTag(corTurno, iconHorario, labelTurno),
                          // Caso seja urgente, insere a tag em vermelho logo ao lado[cite: 1]
                          if (isUrgente) ...[
                            const SizedBox(width: AppDimensions.spaceSmall),
                            _buildUrgenteTag(),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spaceMedium),
                      _buildClienteInfo(nomeCliente, tituloServico),
                      const SizedBox(height: AppDimensions.spaceLarge),
                      const Divider(color: AppColors.borderLight, height: 1),
                      const SizedBox(height: AppDimensions.spaceMedium),
                      _buildEnderecoAcoes(
                        context: context,
                        rua: rua,
                        numero: numero,
                        bairro: bairro,
                        apartamento: apartamento,
                        telefone: telefone,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// [uso] Renderiza o marcador visual correspondente ao turno agendado do atendimento.
  Widget _buildTurnoTag(
    Color corFaixa,
    IconData iconHorario,
    String labelTurno,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceSmall,
        vertical: AppDimensions.spaceXSmall,
      ),
      decoration: BoxDecoration(
        color: corFaixa.withAlpha((255 * 0.15).round()),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconHorario,
            size: AppDimensions.iconSizeXSmall,
            color: corFaixa,
          ),
          const SizedBox(width: AppDimensions.spaceSmall),
          Text(
            labelTurno,
            style: AppTextStyles.caption.copyWith(color: corFaixa),
          ),
        ],
      ),
    );
  }

  /// [uso] Cria a tag vermelha indicativa de alta prioridade para o atendimento.
  Widget _buildUrgenteTag() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceSmall,
        vertical: AppDimensions.spaceXSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.error.withAlpha((255 * 0.15).round()),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department_outlined,
            size: AppDimensions.iconSizeXSmall,
            color: AppColors.error,
          ),
          const SizedBox(width: AppDimensions.spaceXSmall),
          Text(
            "URGENTE",
            style: AppTextStyles.caption.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// [uso] Agrupa e exibe o nome do cliente e a descrição sumária do serviço solicitado.
  Widget _buildClienteInfo(String nomeCliente, String tituloServico) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          AppIcons.dadosPessoaisSection,
          size: AppDimensions.iconSizeMedium,
          color: AppColors.textPrimary,
        ),
        const SizedBox(width: AppDimensions.spaceSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nomeCliente,
                style: AppTextStyles.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppDimensions.spaceXSmall),
              Text(
                tituloServico,
                style: AppTextStyles.bodyMediumSecondary,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// [uso] Monta o bloco textual com os dados de localização e os botões de ação externos.
  Widget _buildEnderecoAcoes({
    required BuildContext context,
    required String rua,
    required String numero,
    required String bairro,
    required String apartamento,
    required String telefone,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSectionHeader(
                icon: Icons.location_on_outlined,
                title: 'ENDEREÇO',
              ),
              if (rua.isNotEmpty)
                Text(
                  '$rua, $numero',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (bairro.isNotEmpty)
                Text(bairro, style: AppTextStyles.bodyMediumSecondary),
              const SizedBox(height: AppDimensions.spaceMedium),
              if (telefone.isNotEmpty) _buildTelefoneChip(telefone),
            ],
          ),
        ),
        const SizedBox(width: AppDimensions.spaceSmall),
        _buildActionButtons(
          context: context,
          telefone: telefone,
          rua: rua,
          numero: numero,
          apartamento: apartamento,
          bairro: bairro,
        ),
      ],
    );
  }

  /// [uso] Renderiza um atalho rápido interativo exibindo o número do telefone.
  Widget _buildTelefoneChip(String telefone) {
    return InkWell(
      onTap: () => LauncherUtils.abrirWhatsApp(telefone),
      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceSmall,
          vertical: AppDimensions.spaceXSmall,
        ),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              AppIcons.telefone,
              size: AppDimensions.iconSizeXSmall,
              color: AppColors.textDisabled,
            ),
            const SizedBox(width: AppDimensions.spaceSmall),
            Text(telefone, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }

  /// [uso] Constrói a coluna vertical contendo as ações de discagem, chat e GPS.
  Widget _buildActionButtons({
    required BuildContext context,
    required String telefone,
    required String rua,
    required String numero,
    required String apartamento,
    required String bairro,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _ActionButton(
          tooltip: 'Ligar',
          icon: Icons.phone,
          color: AppColors.textPrimary,
          onPressed: () => LauncherUtils.fazerLigacao(telefone),
        ),
        const SizedBox(height: AppDimensions.spaceMedium),
        _ActionButton(
          tooltip: 'WhatsApp',
          icon: AppIcons.chat,
          color: AppColors.success,
          onPressed: () => LauncherUtils.abrirWhatsApp(telefone),
        ),
        if (rua.isNotEmpty || bairro.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.spaceMedium),
          _ActionButton(
            tooltip: 'Abrir no Mapa',
            icon: Icons.map_outlined,
            color: AppColors.primary,
            onPressed: () => LauncherUtils.abrirGoogleMapsPorEndereco(
              rua: rua,
              numero: numero,
              apartamento: apartamento,
              bairro: bairro,
            ),
          ),
        ],
      ],
    );
  }
}

/// [uso] Widget interno que padroniza a estilização visual de todos os botões redondos de ação do card.
class _ActionButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: AppDimensions.iconSizeMedium),
      color: color,
      style: IconButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        padding: const EdgeInsets.all(AppDimensions.spaceMedium),
      ),
    );
  }
}
