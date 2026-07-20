import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

/// Centraliza todas as máscaras de entrada de dados do aplicativo.
class AppFormatters {
  AppFormatters._();

  /// A máscara se adapta para números de 11 dígitos.
  static MaskTextInputFormatter get telefone => MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  /// Máscara para CPF no formato brasileiro: ###.###.###-##
  static final cpf = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  /// Máscara para CNPJ no formato brasileiro: ##.###.###/####-##
  static final cnpj = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
}
