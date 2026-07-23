import 'package:flutter/material.dart';
import 'IA_functions.dart';

/// [Objetivo] Componente de interface para o chat interativo com o assistente virtual (IA).
///
/// [Fluxo]
/// 1. Renderiza a área de mensagens e o campo de texto respeitando a paleta escura do app.
/// 2. Ajusta a cor de destaque da interface dinamicamente conforme a permissão do usuário [isAdmin].
/// 3. Captura o input, bloqueia novas ações durante o processamento [isLoading] e exibe a resposta da IA.
class TelaAssistente extends StatefulWidget {
  final bool isAdmin;

  const TelaAssistente({super.key, this.isAdmin = false});

  @override
  State<TelaAssistente> createState() => _TelaAssistenteState();
}

class _TelaAssistenteState extends State<TelaAssistente> {
  // [Controladores] Gerencia o ciclo de vida do texto inserido no input.
  final TextEditingController _controller = TextEditingController();

  // [Dependência] Instância do serviço de integração com a API de Inteligência Artificial.
  final IA_functions _iaService = IA_functions();

  // [Estado Interno] Variáveis reativas que controlam o texto renderizado e o status de loading.
  String _respostaIA = "Olá! Como posso ajudar você hoje?";
  bool _carregando = false;
  late Color _corPrincipal;

  @override
  void initState() {
    super.initState();
    // [Configuração Visual] Define a cor do botão de envio com base na flag de privilégio.
    _corPrincipal = widget.isAdmin ? Colors.red[900]! : Colors.blue[900]!;
  }

  @override
  void dispose() {
    // [Descarte de Memória] Libera o recurso do controller para evitar memory leaks.
    _controller.dispose();
    super.dispose();
  }

  /// [Objetivo] Dispara o fluxo de requisição para a IA com a pergunta atual do input.
  ///
  /// [Comportamento]
  /// - Interrompe a execução caso o campo esteja vazio.
  /// - Atualiza a UI para o estado de carregamento (_carregando = true).
  /// - Envia a requisição de forma assíncrona para o serviço de IA.
  /// - Retorna o estado normal renderizando o texto de resposta na tela.
  void _enviarPergunta() async {
    if (_controller.text.isEmpty) return;

    setState(() {
      _carregando = true;
      _respostaIA = "Pensando...";
    });

    // [Integração] Invoca o processamento remoto da pergunta submetida pelo usuário.
    final resposta = await _iaService.perguntarParaIA(
      perguntaUsuario: _controller.text,
    );

    // [Segurança de Concorrência] Valida se a tela ainda está ativa antes de reconstruir a árvore do widget.
    if (!mounted) return;

    setState(() {
      _respostaIA = resposta;
      _carregando = false;
    });

    // [Reset] Limpa o campo para a próxima interação do usuário.
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // [Área de Leitura] Contêiner expansível e rolável que renderiza as respostas da IA.
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _respostaIA,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // [Área de Entrada] Composição do campo de digitação emparelhado ao botão de submissão.
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    // [UX] Aciona o envio nativamente através do botão de ação da infraestrutura do teclado.
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _enviarPergunta(),
                    decoration: InputDecoration(
                      hintText: "Ex: Quais clientes atendi ontem?",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // [Ação Principal] Botão reativo que alterna visualmente para um indicador de progresso no loading.
                CircleAvatar(
                  backgroundColor: _corPrincipal,
                  radius: 25,
                  child: _carregando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: _enviarPergunta,
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
