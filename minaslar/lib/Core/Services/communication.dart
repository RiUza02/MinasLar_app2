import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Utilitários para abrir URLs externas, como chamadas telefônicas e WhatsApp.
class LauncherUtils {
  LauncherUtils._();

  /// Inicia uma chamada telefônica para o número fornecido, tratando erros.
  static Future<void> fazerLigacao(String numero) async {
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

  /// Abre uma conversa no WhatsApp com o número fornecido, tratando erros e
  /// adicionando o código do país (Brasil) quando necessário.
  static Future<void> abrirWhatsApp(String numero) async {
    // Remove caracteres não numéricos
    String numeroLimpo = numero.replaceAll(RegExp(r'[^0-9]'), '');
    if (numeroLimpo.isEmpty) return;

    // Adiciona o código do país (Brasil) se não estiver presente
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
}
