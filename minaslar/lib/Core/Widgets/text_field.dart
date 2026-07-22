import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../Design/design_system.dart';

// **[Propósito]** Campo de entrada de texto padronizado e customizado com os tokens visuais do Design System.
// **[Como usar]** AppTextField(controller: _emailController, label: 'E-mail', icon: Icons.email);
class AppTextField extends StatelessWidget {
  // **[Parâmetros]** controller -> Gerencia o texto digitado; label -> Texto descritivo do campo; icon -> Ícone de identificação visual.
  final TextEditingController controller;
  final String label;
  final IconData icon;

  // **[Parâmetros]** obscureText -> Oculta os caracteres (ex: senhas); keyboardType -> Define o teclado do OS (e-mail, numérico, etc.).
  final bool obscureText;
  final TextInputType keyboardType;

  // **[Parâmetros]** inputFormatters -> Aplica máscaras visuais (CPF, telefone); validator -> Função de validação de formulário.
  final List<MaskTextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  // **[Parâmetros]** onChanged -> Callback disparado a cada alteração no texto; suffixIcon -> Ícone interativo à direita (ex: ver senha).
  final void Function(String)? onChanged;
  final Widget? suffixIcon;

  // **[Parâmetros]** hintText -> Texto de dica com o campo vazio; textInputAction -> Botão de ação do teclado (concluir, avançar).
  final String? hintText;
  final TextInputAction? textInputAction;

  // **[Parâmetros]** onFieldSubmitted -> Callback disparado ao confirmar no teclado; maxLines -> Altura em linhas do campo (padrão: 1).
  final void Function(String)? onFieldSubmitted;
  final int maxLines;

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
    this.maxLines = 1,
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
      maxLines: maxLines,
      // Aplica a tipografia padronizada no texto inserido pelo usuário.
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.inputLabel,
        hintText: hintText,
        hintStyle: AppTextStyles.inputHint,
        // Ícone fixo à esquerda estilizado com a cor primária da aplicação.
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
