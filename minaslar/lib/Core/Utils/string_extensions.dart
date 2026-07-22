// **[Propósito]** Extensão com utilitários para manipulação e formatação de Strings no padrão visual da aplicação.
// **[Como usar]** String nomeFormatado = "  joão  da SILVA  ".toTitleCase(); // Retorna: "João Da Silva"
extension StringCasingExtension on String {
  // **[Propósito]** Normaliza espaçamentos e converte uma string para o formato "Title Case" (primeira letra de cada palavra em maiúscula).
  // **[Retorno]** String -> Texto limpo e formatado.
  String toTitleCase() {
    if (trim().isEmpty) return "";

    return trim()
        // Divide o texto com base em qualquer quantidade de espaços em branco contínuos.
        .split(RegExp(r'\s+'))
        .map((word) {
          if (word.isEmpty) return "";
          if (word.length == 1) return word.toUpperCase();

          // Garante a inicial maiúscula e converte o restante da palavra para minúsculo.
          return "${word[0].toUpperCase()}${word.substring(1).toLowerCase()}";
        })
        .join(' ');
  }
}
