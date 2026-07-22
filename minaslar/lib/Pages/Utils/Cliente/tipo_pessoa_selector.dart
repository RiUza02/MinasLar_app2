import '../../../../Core/Design/design_system.dart';

// **[Propósito]** Componente visual de seleção (estilo toggle ou segmented control) que permite ao usuário escolher o tipo de cliente, alternando facilmente entre "Pessoa Física" e "Pessoa Jurídica".
// **[Como usar]** TipoPessoaSelector(isPessoaFisica: _isFisica, onChanged: (valor) => setState(() => _isFisica = valor));
class TipoPessoaSelector extends StatelessWidget {
  final bool isPessoaFisica;
  final ValueChanged<bool> onChanged;

  // **[Propósito]** Constrói o seletor exigindo o estado atual da seleção (true para Pessoa Física) e a função de callback que será acionada informando a nova escolha.
  const TipoPessoaSelector({
    super.key,
    required this.isPessoaFisica,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(child: _buildRadioButton(context, "Pessoa Física", true)),
          Container(width: 1, height: 40, color: AppColors.borderLight),
          Expanded(child: _buildRadioButton(context, "Pessoa Jurídica", false)),
        ],
      ),
    );
  }

  // **[Propósito]** Método auxiliar responsável por construir cada botão individualmente, aplicando estilos visuais de destaque (cor e peso da fonte) caso a opção represente o valor selecionado.
  Widget _buildRadioButton(BuildContext context, String title, bool value) {
    final isSelected = isPessoaFisica == value;
    final activeColor = AppColors.primaryAlternative;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spaceMedium,
        ),
        child: Center(
          child: Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected ? activeColor : AppColors.textDisabled,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
