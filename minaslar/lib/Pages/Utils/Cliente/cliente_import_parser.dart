import '../../../../Core/Errors/exceptions.dart';

// **[Propósito]** Objeto de transferência de dados (DTO) utilizado para armazenar temporariamente as informações extraídas de um texto bruto antes de preencher o formulário do cliente.
class ImportedClienteData {
  final String? nome;
  final String? telefone;
  final String? rua;
  final String? numero;
  final String? bairro;

  ImportedClienteData({
    this.nome,
    this.telefone,
    this.rua,
    this.numero,
    this.bairro,
  });
}

// **[Propósito]** Utilitário de parsing responsável por interpretar, higienizar e validar textos brutos colados pelo usuário, convertendo-os em uma estrutura de dados tipada pronta para preencher os formulários.
// **[Como usar]** final parser = ClienteImportParser(); / final dados = parser.parse(textoCopiado);
class ClienteImportParser {
  // **[Propósito]** Processa o texto multilinha, aplica regras de negócio de validação (ex: verifica se telefone contém letras) e mapeia sequencialmente as linhas limpas para as propriedades do cliente.
  // **[Parâmetros]** rawText (String) -> O texto bruto colado da área de transferência.
  // **[Retorno]** ImportedClienteData -> Estrutura contendo os campos extraídos. Propriedades não encontradas (falta de linhas) retornam null.
  // **[Exceções]** ValidationException -> Lançada caso o texto seja vazio ou a validação de formato do telefone falhe.
  ImportedClienteData parse(String rawText) {
    if (rawText.trim().isEmpty) {
      throw const ValidationException("O texto para importação está vazio.");
    }

    final lines = rawText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.length > 1 && RegExp(r'[a-zA-Z]').hasMatch(lines[1])) {
      throw const ValidationException(
        "A 2ª linha (Telefone) não deve conter letras.",
      );
    }

    return ImportedClienteData(
      nome: lines.isNotEmpty ? lines[0] : null,
      telefone: lines.length > 1
          ? lines[1].replaceAll(RegExp(r'[^0-9]'), '')
          : null,
      rua: lines.length > 2 ? lines[2] : null,
      numero: lines.length > 3 ? lines[3] : null,
      bairro: lines.length > 4 ? lines[4] : null,
    );
  }
}
