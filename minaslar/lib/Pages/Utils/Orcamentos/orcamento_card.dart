import '../../../Core/Design/design_system.dart';
import '../../../Core/Services/communication.dart';
import '../../../Core/Design/borders.dart';
import '../../../Core/Widgets/widgets.dart';

// **[Propósito]** Componente visual em formato de cartão utilizado na página principal (HomePage) para exibir os detalhes essenciais de um orçamento. Implementa uma lógica rigorosa de 6 níveis de prioridade (Urgente, Atrasado, Garantia, Pendente, Concluído e Sem data) que define o destaque visual (cores e bordas) e os marcadores de status. Apresenta também informações de cliente, endereço de atendimento e atalhos de ações rápidas.
// **[Como usar]** OrcamentoCard(orcamento: mapDoOrcamento, onCardTap: () => _abrirDetalhesDoOrcamento());
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
    // Tratamento seguro do cliente vindo via JOIN (como Map único ou List)
    final rawCliente = orcamento['clientes'];
    final Map<String, dynamic> cliente = rawCliente is List
        ? (rawCliente.isNotEmpty
              ? rawCliente.first as Map<String, dynamic>
              : {})
        : (rawCliente as Map<String, dynamic>? ?? {});

    // Extração segura de strings
    final nomeCliente = (cliente['nome'] ?? 'Cliente').toString();
    final telefone = (cliente['telefone'] ?? '').toString();
    final rua = (cliente['rua'] ?? '').toString();
    final numero = (cliente['numero'] ?? 'S/N').toString();
    final apartamento = (cliente['apartamento'] ?? '').toString();
    final bairro = (cliente['bairro'] ?? '').toString();
    final tituloServico = (orcamento['titulo'] ?? '').toString();

    // Extrações de booleanos e datas para o cálculo rigoroso das 6 prioridades
    final bool isEntregue = orcamento['entregue'] == true;
    final bool isUrgente = orcamento['eh_urgente'] == true;
    final bool isRetorno = orcamento['eh_retorno'] == true;

    final dataEntregaStr = orcamento['data_entrega']?.toString();
    DateTime? dataEntregaDateOnly;
    if (dataEntregaStr != null &&
        dataEntregaStr.isNotEmpty &&
        dataEntregaStr != 'null') {
      final parsed = DateTime.tryParse(dataEntregaStr);
      if (parsed != null) {
        dataEntregaDateOnly = DateUtils.dateOnly(parsed);
      }
    }

    final hoje = DateUtils.dateOnly(DateTime.now());
    final bool isAtrasado =
        !isEntregue &&
        dataEntregaDateOnly != null &&
        dataEntregaDateOnly.isBefore(hoje);

    // --- APLICAÇÃO RIGOROSA DAS 6 REGRAS DE PRIORIDADE ---
    String statusLabel;
    Color corDestaque;
    Border cardBorder;

    if (!isEntregue && isUrgente) {
      // 1º: Urgente e não entregue -> Vermelho
      statusLabel = "URGENTE";
      corDestaque = Colors.red;
      cardBorder = AppBorders.urgent;
    } else if (!isEntregue && isAtrasado) {
      // 2º: Data de entrega inferior ao dia de hj -> Laranja
      statusLabel = "ATRASADO";
      corDestaque = Colors.orange;
      cardBorder = Border(left: BorderSide(color: corDestaque, width: 5));
    } else if (!isEntregue && isRetorno) {
      // 3º: Marcados como garantia (ou retorno) -> Verde
      statusLabel = "GARANTIA";
      corDestaque = Colors.green;
      cardBorder = Border(left: BorderSide(color: corDestaque, width: 5));
    } else if (!isEntregue && dataEntregaDateOnly != null) {
      // 4º: Data de entrega superior (ou igual) ao dia de hj -> Azul
      statusLabel = "PENDENTE";
      corDestaque = Colors.blue;
      cardBorder = Border(left: BorderSide(color: corDestaque, width: 5));
    } else if (isEntregue) {
      // 5º: Concluídos -> Azul com nome riscado
      statusLabel = "CONCLUÍDO";
      corDestaque = Colors.blue;
      cardBorder = Border(left: BorderSide(color: corDestaque, width: 5));
    } else {
      // 6º: Sem data -> Azul, mas sem data
      statusLabel = "SEM DATA";
      corDestaque = Colors.blue;
      cardBorder = Border(left: BorderSide(color: corDestaque, width: 5));
    }

    // Configurações do Turno (Manhã/Tarde)
    final horarioTexto = (orcamento['horario_do_dia'] ?? 'Manhã').toString();
    final isTarde = horarioTexto.toLowerCase() == 'tarde';
    final Color corTurno = isTarde
        ? AppColors.afternoonShift
        : AppColors.morningShift;
    final IconData iconHorario = isTarde ? AppIcons.tarde : AppIcons.manha;
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
              // Linha lateral decorativa que reflete visualmente a prioridade definida pelas 6 regras.
              Container(
                width: AppDimensions.spaceSmall,
                color: corDestaque.withValues(alpha: 0.15),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.spaceLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Ícone e identificador do Turno (Manhã ou Tarde)
                          _buildTurnoTag(corTurno, iconHorario, labelTurno),
                          // Tag visual do Status de acordo com a prioridade
                          _buildStatusTag(statusLabel, corDestaque),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spaceMedium),
                      _buildClienteInfo(
                        nomeCliente,
                        tituloServico,
                        isEntregue: isEntregue,
                      ),
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

  // **[Propósito]** Renderiza o marcador visual correspondente ao turno agendado do atendimento.
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
        color: corFaixa.withValues(alpha: 0.15),
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

  // **[Propósito]** Cria a tag visual do status (Urgente, Atrasado, Garantia, Concluído, etc.)
  Widget _buildStatusTag(String label, Color cor) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceSmall,
        vertical: AppDimensions.spaceXSmall,
      ),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: cor.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: cor,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // **[Propósito]** Agrupa e exibe o nome do cliente e a descrição do serviço, aplicando risco no texto caso concluído.
  Widget _buildClienteInfo(
    String nomeCliente,
    String tituloServico, {
    required bool isEntregue,
  }) {
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
                style: AppTextStyles.titleMedium.copyWith(
                  decoration: isEntregue ? TextDecoration.lineThrough : null,
                  color: isEntregue
                      ? AppColors.textDisabled
                      : AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppDimensions.spaceXSmall),
              Text(
                tituloServico,
                style: AppTextStyles.bodyMediumSecondary.copyWith(
                  decoration: isEntregue ? TextDecoration.lineThrough : null,
                  color: isEntregue ? AppColors.textDisabled : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // **[Propósito]** Monta o bloco textual com os dados de localização e os botões de ação externos.
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
                icon: AppIcons.endereco,
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

  // **[Propósito]** Renderiza um atalho rápido interativo exibindo o número do telefone.
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

  // **[Propósito]** Constrói a coluna vertical contendo as ações de discagem, chat e GPS.
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
          icon: AppIcons.ligar,
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
            icon: AppIcons.mapa,
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

// **[Propósito]** Componente utilitário privado que padroniza a estilização visual de todos os botões redondos de ação rápida (ligar, WhatsApp, mapa) do card.
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
