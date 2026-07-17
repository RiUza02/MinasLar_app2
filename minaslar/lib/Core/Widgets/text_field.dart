import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../design_system/design_system.dart';

/// Campo de entrada de dados (Input) padronizado para o projeto.
/// [Onde usar]: Deve ser utilizado em absolutamente todos os formulários do app
/// (Login, Cadastro, Recuperação de Senha, Edição de Endereço, etc.) em substituição
/// ao [TextFormField] ou [TextField] nativos do Flutter.
class AppTextField extends StatelessWidget {
  /// Controlador do texto digitado pelo usuário.
  final TextEditingController controller;

  /// Rótulo superior do campo (ex: "E-mail", "Senha", "CPF").
  final String label;

  /// Ícone fixo exibido à esquerda do campo para identificação rápida.
  final IconData icon;

  /// Define se o texto deve ser ocultado. Usado para campos de senhas ou tokens (padrão: `false`).
  final bool obscureText;

  /// Tipo de teclado exibido no dispositivo (numérico, e-mail, telefone, texto normal).
  final TextInputType keyboardType;

  /// Lista de máscaras de formatação (geralmente vindas da classe [AppFormatters]).
  final List<MaskTextInputFormatter>? inputFormatters;

  /// Função executada ao submeter o formulário para checar se o dado é válido.
  final String? Function(String?)? validator;

  /// Callback disparado a cada caractere digitado ou alterado pelo usuário.
  final void Function(String)? onChanged;

  /// Widget opcional à direita (muito usado para o botão de "mostrar/ocultar senha").
  final Widget? suffixIcon;

  /// Texto de exemplo/dica exibido em cinza quando o campo está vazio (ex: "(00) 00000-0000").
  final String? hintText;

  /// Ação do botão de confirmação do teclado (ex: "next", "done").
  final TextInputAction? textInputAction;

  /// Callback disparado quando o usuário submete o campo (pressiona "done" no teclado).
  final void Function(String)? onFieldSubmitted;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.suffixIcon,
    this.hintText,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      validator: validator,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      style: AppTextStyles.bodyMedium, // Texto principal digitado pelo usuário
      decoration: InputDecoration(
        labelText: label,
        // Consome o estilo discreto do Design System
        labelStyle: AppTextStyles.inputLabel,
        hintText: hintText,
        // Consome o estilo de ajuda/transparente do Design System
        hintStyle: AppTextStyles.inputHint,
        prefixIcon: Icon(
          icon,
          color: AppColors.primary,
          size: AppDimensions.iconSizeMedium,
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
