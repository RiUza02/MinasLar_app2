import 'package:flutter/material.dart';
import 'colors.dart';
import 'dimensions.dart';
import 'text_styles.dart';

class AppTheme {
  AppTheme._();

  /// [Uso]: Estilo para botões secundários ou de ação alternativa, utilizando o fundo dos cards e texto principal.
  static ButtonStyle get secondaryButton {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.cardBackground,
      foregroundColor: AppColors.textPrimary,
      minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceXLarge,
        vertical: AppDimensions.spaceMedium,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      textStyle: AppTextStyles.button,
    );
  }

  /// [Uso]: Tema principal escuro da aplicação. Padroniza cores, fontes e comportamentos de todos os componentes nativos do Flutter.
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,

      /// [Uso]: Configura a paleta base para widgets que utilizam o esquema padrão do Flutter[cite: 5].
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.textPrimary,
        surface: AppColors
            .cardBackground, // Cards herdam essa cor automaticamente[cite: 5]
      ),

      /// [Uso]: Aplica o estilo estrutural e tipográfico em todas as AppBars do app[cite: 5].
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.titleLarge,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),

      /// [Uso]: Aplica os espaçamentos, bordas e cores em todas as caixas de entrada (TextFields)[cite: 5].
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textDisabled),
        prefixIconColor: AppColors.primary,
        contentPadding: const EdgeInsets.all(AppDimensions.spaceLarge),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(
            color: AppColors.borderFocused,
            width: 2,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
      ),

      /// [Uso]: Injeta altura, cantos e fontes padronizadas em todos os ElevatedButton do projeto[cite: 5].
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceXLarge,
            vertical: AppDimensions.spaceMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      /// [Uso]: Padroniza os botões de texto, como o link "Faça Login"[cite: 5].
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
