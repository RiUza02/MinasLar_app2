import '../../../../Core/Errors/exceptions.dart';

/// [uso] Armazena os dados extraídos do texto de importação
/// para preencher o formulário do cliente.
class ImportedClienteData {
  /// Nome do cliente.
  final String? nome;

  /// Telefone do cliente.
  final String? telefone;

  /// Rua do endereço.
  final String? rua;

  /// Número do endereço.
  final String? numero;

  /// Bairro do endereço.
  final String? bairro;

  ImportedClienteData({
    this.nome,
    this.telefone,
    this.rua,
    this.numero,
    this.bairro,
  });
}

/// [uso] Processa o texto informado pelo usuário e converte
/// seu conteúdo em um objeto [ImportedClienteData].
class ClienteImportParser {
  /// [uso] Valida e extrai os dados do texto importado.
  ///
  /// Espera as informações na ordem:
  /// Nome, Telefone, Rua, Número e Bairro.
  ImportedClienteData parse(String rawText) {
    // Verifica se o texto foi informado.
    if (rawText.trim().isEmpty) {
      throw const ValidationException("O texto para importação está vazio.");
    }

    // Divide o texto em linhas válidas.
    final lines = rawText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    // Valida se o telefone contém apenas números.
    if (lines.length > 1 && RegExp(r'[a-zA-Z]').hasMatch(lines[1])) {
      throw const ValidationException(
        "A 2ª linha (Telefone) não deve conter letras.",
      );
    }

    // Monta o objeto com os dados encontrados.
    return ImportedClienteData(
      nome: lines.isNotEmpty ? lines[0] : null,

      // Remove qualquer caractere que não seja número.
      telefone: lines.length > 1
          ? lines[1].replaceAll(RegExp(r'[^0-9]'), '')
          : null,

      rua: lines.length > 2 ? lines[2] : null,
      numero: lines.length > 3 ? lines[3] : null,
      bairro: lines.length > 4 ? lines[4] : null,
    );
  }
}
