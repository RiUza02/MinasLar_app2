import '../../../../Core/Design/design_system.dart';

/// [uso] Campo de texto estilizado para buscas em listas.
class ClienteSearchBar extends StatelessWidget {
  final TextEditingController controller;

  const ClienteSearchBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Usa um ValueListenableBuilder para reconstruir o sufixo do ícone
    // de forma reativa sem precisar de um StatefulWidget completo.
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        return TextField(
          controller: controller,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: "Nome, Endereço ou Telefone...",
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textDisabled,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.textDisabled,
              size: AppDimensions.iconSizeMedium,
            ),
            suffixIcon: value.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.clear,
                      color: AppColors.textDisabled,
                      size: AppDimensions.iconSizeMedium,
                    ),
                    onPressed: () => controller.clear(),
                  )
                : null,
            filled: true,
            fillColor: AppColors.inputBackground,
            contentPadding: const EdgeInsets.symmetric(
              vertical: AppDimensions.spaceMedium,
              horizontal: AppDimensions.spaceSmall,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              borderSide: const BorderSide(
                color: AppColors.borderFocused,
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }
}
