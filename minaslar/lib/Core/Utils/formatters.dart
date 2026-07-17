import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

/// Centraliza todas as máscaras de entrada de dados do aplicativo.
class AppFormatters {
  AppFormatters._();

  /// Máscara padrão para telefone/celular no formato brasileiro: (##) #####-####
  static final telefone = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
}
