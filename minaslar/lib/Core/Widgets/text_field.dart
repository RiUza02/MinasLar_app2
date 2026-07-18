import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../Design/design_system.dart';

/// Campo de entrada de dados (Input) padronizado e estilizado para o ecossistema do aplicativo.
///
/// **[Onde usar]**: Em absolutamente todos os formulários do app (Login, Cadastro, Configurações, etc.),
/// substituindo de forma mandatória o [TextFormField] ou [TextField] nativos do Flutter.
class AppTextField extends StatelessWidget {
  /// Controlador responsável pela captura e gerenciamento do texto digitado.
  final TextEditingController controller;

  /// Texto descritivo exibido como rótulo do campo (ex: "E-mail", "Senha").
  final String label;

  /// Ícone de identificação visual posicionado no início do campo.
  final IconData icon;

  /// Oculta os caracteres digitados. Ideal para mascarar senhas.
  final bool obscureText;

  /// Configura a variante do teclado nativo do dispositivo (ex: numérico, e-mail).
  final TextInputType keyboardType;

  /// Lista de máscaras de formatação visual (ex: máscaras de CPF ou Telefone).
  final List<MaskTextInputFormatter>? inputFormatters;

  /// Bloco de lógica para validação de erros (regras de campos obrigatórios, formatos, etc.).
  final String? Function(String?)? validator;

  /// Evento disparado imediatamente a cada modificação do texto no input.
  final void Function(String)? onChanged;

  /// Elemento interativo opcional posicionado no final do campo (ex: botão de alternar visibilidade da senha).
  final Widget? suffixIcon;

  /// Texto de dica ou exemplo exibido enquanto o campo estiver vazio (ex: "000.000.000-00").
  final String? hintText;

  /// Define o comportamento do botão de ação do teclado virtual (ex: Avançar, Concluir).
  final TextInputAction? textInputAction;

  /// Evento executado no momento em que o usuário confirma a ação final no teclado.
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
      // Aplica a tipografia padrão para os dados inseridos pelo usuário
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.inputLabel,
        hintText: hintText,
        hintStyle: AppTextStyles.inputHint,
        // Ícone inicial com a identidade visual primária do projeto
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
