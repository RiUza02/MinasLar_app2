/// Extensão com utilitários para manipulação de Strings.
extension StringCasingExtension on String {
  /// [uso] Converte um texto para o formato "Title Case".
  /// "  joão  da SILVA  " -> "João da Silva"
  String toTitleCase() {
    // Retorna uma string vazia caso o texto contenha apenas espaços.
    if (trim().isEmpty) return "";

    return trim()
        // Divide a frase em palavras, ignorando múltiplos espaços.
        .split(RegExp(r'\s+'))
        .map((word) {
          // Ignora palavras vazias.
          if (word.isEmpty) return "";

          // Trata palavras com apenas um caractere.
          if (word.length == 1) return word.toUpperCase();

          // Primeira letra maiúscula e restante minúsculo.
          return "${word[0].toUpperCase()}${word.substring(1).toLowerCase()}";
        })
        // Junta as palavras com um único espaço.
        .join(' ');
  }
}
