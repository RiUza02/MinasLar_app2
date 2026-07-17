import 'package:url_launcher/url_launcher.dart';

/// Utilitários para abrir URLs externas, como chamadas telefônicas e WhatsApp.
class LauncherUtils {
  LauncherUtils._();

  /// Inicia uma chamada telefônica para o número fornecido.
  static Future<void> fazerLigacao(String numero) async {
    final Uri url = Uri(scheme: 'tel', path: numero);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  /// Abre uma conversa no WhatsApp com o número fornecido.
  static Future<void> abrirWhatsApp(String numero) async {
    // Remove caracteres não numéricos
    final numeroLimpo = numero.replaceAll(RegExp(r'[^0-9]'), '');
    // Adiciona o código do país (Brasil) se não estiver presente
    final String numeroFinal = numeroLimpo.length >= 11
        ? '55$numeroLimpo'
        : numeroLimpo;

    final Uri url = Uri.parse("https://wa.me/$numeroFinal");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
