import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- CORES DE IDENTIDADE E ESTRUTURA ---

  /// [Uso]: Cor de destaque principal. Usada no fundo dos botões de ação,
  static const Color primary = Colors.blue;

  /// [Uso]: Cor de destaque para administradores. Usada em botões e elementos de destaque.
  static const Color adminColor = Colors.amber;

  /// [Uso]: Cor de destaque principal alternativa. Usada para adminstradores.
  static const Color primaryAlternative = Color(0xFFD32F2F);

  /// [Uso]: Fundo absoluto do aplicativo. Aplicado diretamente no
  static const Color background = Colors.black;

  /// [Uso]: Fundo de blocos, cartões e agrupamentos de formulários.
  static const Color cardBackground = Color(0xFF212121);

  /// [Uso]: Fundo de caixas de texto (TextFields) para dar profundidade.
  static const Color inputBackground = Colors.black26;

  // --- CORES DE TEXTO ---

  /// [Uso]: Títulos de páginas, textos dentro de botões e qualquer informação
  static const Color textPrimary = Colors.white;

  /// [Uso]: Textos longos, descrições de serviços, subtítulos e labels (rótulos)
  static const Color textSecondary = Colors.white70;

  /// [Uso]: Placeholders (textos de dica dentro do input antes de digitar),
  static const Color textDisabled = Colors.white54;

  // --- CORES DE BORDAS E DIVISORES ---

  /// [Uso]: Contorno padrão de caixas de texto (TextFields) quando estão ociosas
  static const Color border = Colors.white54;

  /// [Uso]: Contorno da caixa de texto (TextField) que o usuário está editando ativamente.
  static const Color borderFocused = Colors.blue;

  /// [Uso]: Linhas finas de separação (`Divider`) dentro de cards para dividir
  static const Color borderLight = Colors.white24;

  /// [Uso]: Cor para orçamentos agendados para o turno da manhã.
  static const Color morningShift = Color(0xFFFBC02D);

  /// [Uso]: borda para orçamentos agendados para o turno da tarde.
  static const Color afternoonShift = Color(0xFFEF6C00);

  // --- CORES DE STATUS ---

  /// [Uso]: Indicações de sucesso. Usado no fundo do botão "Salvar no Supabase"
  static const Color success = Colors.green;

  /// [Uso]: Indicações de falha ou atenção. Usado em textos de validação de formulário
  static const Color error = Colors.redAccent;
}
