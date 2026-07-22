import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

// **[Propósito]** Centraliza a abertura de links e aplicativos externos do sistema operacional (Telefone, WhatsApp e Google Maps).
// **[Como usar]** LauncherUtils.fazerLigacao('32999999999'); / LauncherUtils.abrirWhatsApp('32999999999');
class LauncherUtils {
  LauncherUtils._();

  // **[Propósito]** Aciona o discador nativo do sistema operacional para iniciar chamadas telefônicas.
  // **[Parâmetros]** numero (String) -> Número de telefone (com ou sem formatação de caracteres visuais).
  // **[Como usar]** await LauncherUtils.fazerLigacao('(32) 99999-9999');
  static Future<void> fazerLigacao(String numero) async {
    // Remove qualquer caractere que não seja número para evitar erros de leitura no discador.
    final numeroLimpo = numero.replaceAll(RegExp(r'[^0-9]'), '');
    if (numeroLimpo.isEmpty) return;

    final Uri url = Uri(scheme: 'tel', path: numeroLimpo);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        if (kDebugMode) debugPrint("Não foi possível realizar a ligação.");
      }
    } catch (e) {
      if (kDebugMode) debugPrint("Erro ao tentar ligar: $e");
    }
  }

  // **[Propósito]** Redireciona para o WhatsApp iniciando um chat direto, sem necessidade de adicionar aos contatos.
  // **[Parâmetros]** numero (String) -> Número de telefone com DDD ou DDI (ex: 32999999999).
  // **[Como usar]** await LauncherUtils.abrirWhatsApp('32988887777');
  static Future<void> abrirWhatsApp(String numero) async {
    String numeroLimpo = numero.replaceAll(RegExp(r'[^0-9]'), '');
    if (numeroLimpo.isEmpty) return;

    // Normaliza strings numéricas adicionando o DDI do Brasil (+55) caso o número tenha apenas DDD.
    if (numeroLimpo.length >= 10 && numeroLimpo.length <= 11) {
      numeroLimpo = "55$numeroLimpo";
    } else if ((numeroLimpo.length == 12 || numeroLimpo.length == 13) &&
        numeroLimpo.startsWith('0')) {
      numeroLimpo = "55${numeroLimpo.substring(1)}";
    }

    final Uri url = Uri.parse("https://wa.me/$numeroLimpo");
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (kDebugMode) debugPrint("Não foi possível abrir o WhatsApp.");
      }
    } catch (e) {
      if (kDebugMode) debugPrint("Erro ao tentar abrir o WhatsApp: $e");
    }
  }

  // **[Propósito]** Executa a busca de um endereço completo diretamente no aplicativo nativo do Google Maps.
  // **[Parâmetros]** rua, numero, bairro (String obrigatórios) / apartamento, cidade, estado (String opcionais/com default).
  // **[Como usar]** await LauncherUtils.abrirGoogleMapsPorEndereco(rua: 'Av. Barão do Rio Branco', numero: '1000', bairro: 'Centro');
  static Future<void> abrirGoogleMapsPorEndereco({
    required String rua,
    required String numero,
    String? apartamento,
    required String bairro,
    String cidade = 'Juiz de Fora',
    String estado = 'MG',
  }) async {
    // Une os fragmentos de texto limpando os valores opcionais nulos ou vazios.
    final String enderecoCompleto = [
      rua,
      numero,
      if (apartamento != null && apartamento.isNotEmpty) 'Apto $apartamento',
      bairro,
      '$cidade - $estado',
    ].where((s) => s.isNotEmpty).join(', ');

    if (enderecoCompleto.trim().length < 10) return;

    // Codifica caracteres especiais da string (espaços, acentos) para o formato seguro em URLs HTTP.
    final Uri googleMapsUrl = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(enderecoCompleto)}",
    );

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        if (kDebugMode) debugPrint("Não foi possível abrir o mapa.");
      }
    } catch (e) {
      if (kDebugMode) debugPrint("Erro ao tentar abrir o mapa: $e");
    }
  }
}
