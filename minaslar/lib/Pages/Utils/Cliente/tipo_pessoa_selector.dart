import '../../../../Core/Design/design_system.dart';

/// [uso] Permite selecionar o tipo de cliente entre
/// Pessoa Física e Pessoa Jurídica.
class TipoPessoaSelector extends StatelessWidget {
  /// Indica se a opção selecionada é Pessoa Física.
  final bool isPessoaFisica;

  /// Callback executado ao alterar a seleção.
  final ValueChanged<bool> onChanged;

  const TipoPessoaSelector({
    super.key,
    required this.isPessoaFisica,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Estilo do seletor.
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          // Opção Pessoa Física.
          Expanded(child: _buildRadioButton(context, "Pessoa Física", true)),

          // Divisor entre as opções.
          Container(width: 1, height: 40, color: AppColors.borderLight),

          // Opção Pessoa Jurídica.
          Expanded(child: _buildRadioButton(context, "Pessoa Jurídica", false)),
        ],
      ),
    );
  }

  /// [uso] Cria uma opção de seleção do tipo de pessoa.
  Widget _buildRadioButton(BuildContext context, String title, bool value) {
    // Verifica se esta opção está selecionada.
    final isSelected = isPessoaFisica == value;

    // Cor utilizada para a opção ativa.
    final activeColor = AppColors.primaryAlternative;

    return InkWell(
      // Atualiza a seleção.
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
