import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  AppTextStyles._();

  /// [Uso]: Título principal do topo da tela. Configurado automaticamente
  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  /// [Uso]: Títulos de blocos internos ou seções de formulários
  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  /// [Uso]: Mensagens de destaque em áreas limpas, introduções ou alertas centrais
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    color: AppColors.textSecondary,
  );

  /// [Uso]: Textos comuns de leitura do dia a dia, como dados exibidos dentro de tabelas,
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  /// [Uso]: Textos secundários do dia a dia, como perguntas de rodapé ou legendas de apoio.
  static const TextStyle bodyMediumSecondary = TextStyle(
    fontSize: 16,
    color: AppColors.textSecondary,
  );

  /// [Uso]: Estilo do texto interno de botões. Possui peso semi-bold (600)
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// [Uso]: Rótulos principais de seção (ex: "CRIE SUA CONTA").
  static const TextStyle overline = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.textSecondary,
    letterSpacing: 1.2,
  );

  /// [Uso]: Rótulos internos de cards (ex: "DADOS PESSOAIS", "SEGURANÇA").
  static const TextStyle cardHeader = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.textDisabled,
    letterSpacing: 1.2,
  );

  /// [Uso]: Pequenos textos de validação ou legendas abaixo de campos.
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
  );

  /// [Uso]: Estilo para o rótulo (Label) dos campos de texto.
  static TextStyle get inputLabel => TextStyle(
    fontSize: 14,
    color: AppColors.textDisabled.withValues(alpha: 0.3),
    fontWeight: FontWeight.w400,
  );

  /// [Uso]: Estilo para o texto de dica, Puramente como guia de preenchimento.
  static TextStyle get inputHint => TextStyle(
    fontSize: 13,
    color: AppColors.textDisabled.withValues(alpha: 0.15),
    fontWeight: FontWeight.w400,
  );
}
