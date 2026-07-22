import '../../../../Core/Design/design_system.dart';

// **[Propósito]** Modelo de dados simples que representa um item individual na legenda de um gráfico, associando uma cor a um rótulo de texto.
class LegendItem {
  final Color color;
  final String text;
  LegendItem({required this.color, required this.text});
}

// **[Propósito]** Componente visual reutilizável que exibe uma legenda horizontal, mapeando as cores das séries de dados de um gráfico aos seus respectivos significados.
// **[Como usar]** Utilizado geralmente abaixo de componentes de gráficos (como barras ou linhas). Requer uma lista de objetos [LegendItem] contendo as cores e rótulos desejados.
class ChartLegend extends StatelessWidget {
  final List<LegendItem> items;

  const ChartLegend({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: items
          .map(
            // **[Subcomponente: Indicador Visual]** Renderiza cada item da legenda com um pequeno quadrado colorido acompanhado do texto descritivo correspondente.
            (item) => Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spaceSmall,
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: item.color,
                      borderRadius: BorderRadius.circular(
                        2,
                      ), // Bordas levemente arredondadas para um visual mais suave.
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceSmall),
                  Text(item.text, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
