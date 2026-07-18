import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// [uso] Centraliza a abertura de links e aplicativos externos do sistema operacional.
class LauncherUtils {
  LauncherUtils._();

  /// [uso] Aciona o discador nativo do sistema operacional para iniciar chamadas telefônicas.
  static Future<void> fazerLigacao(String numero) async {
    // Remove qualquer caractere que não seja número para evitar erros no discador.
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

  /// [uso] Redireciona o usuário para o aplicativo do WhatsApp iniciando chat direto sem adicionar contato.
  static Future<void> abrirWhatsApp(String numero) async {
    String numeroLimpo = numero.replaceAll(RegExp(r'[^0-9]'), '');
    if (numeroLimpo.isEmpty) return;

    // Normaliza strings numéricas para o padrão DDI (Brasil) + DDD + Número.
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

  /// [uso] Executa a busca de um único endereço específico diretamente no aplicativo do Google Maps.
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

    // Codifica caracteres especiais da string de texto para o padrão aceito em URLs HTTP.
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
