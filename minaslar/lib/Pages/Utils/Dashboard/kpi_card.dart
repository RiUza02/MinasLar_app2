import '../../../../Core/Design/design_system.dart';

// **[Propósito]** Componente visual genérico e reutilizável projetado para exibir indicadores-chave de desempenho (KPIs) de forma padronizada, limpa e direta.
// **[Como usar]** Utilizado amplamente em painéis gerenciais (dashboards) e telas de métricas. Requer a passagem de um título, um valor de destaque, um subtítulo contextual, além de um ícone e sua respectiva cor de ênfase.
class KpiCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final String subtitulo;
  final IconData icone;
  final Color corIcone;

  const KpiCard({
    super.key,
    required this.titulo,
    required this.valor,
    required this.subtitulo,
    required this.icone,
    required this.corIcone,
  });

  @override
  Widget build(BuildContext context) {
    // **[Subcomponente: Layout do Card]** Estrutura o conteúdo em um container delimitado por bordas suaves.
    // Organiza internamente em uma coluna contendo: cabeçalho (título + ícone), o valor principal em destaque tipográfico e um texto auxiliar ao fundo.
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceMedium),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(icone, color: corIcone, size: 20),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceSmall),
          Text(
            valor,
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 24,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }
}
