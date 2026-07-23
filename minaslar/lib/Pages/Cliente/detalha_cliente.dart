import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../Core/Design/design_system.dart';
import '../../Core/Errors/errors.dart';
import '../../Core/Services/communication.dart';
import '../../Core/Utils/formatters.dart';
import '../../Core/Widgets/widgets.dart';
import '../Utils/Cliente/cliente_card.dart';
import '../Utils/Cliente/cliente_header_card.dart';
import '../Utils/Cliente/cliente_orcamentos_history.dart';
import '../../Features/Modelos/cliente_model.dart';
import '../../Features/Repositorios/cliente_repository.dart';
import 'edita_cliente.dart';
import '../Orcamento/cria_orcamento.dart';

/// [Objetivo] Tela de detalhamento completo de um cliente cadastrado.
///
/// [Fluxo] Exibe a ficha cadastral do cliente, atalhos de contato/localização,
/// e o histórico de orçamentos vinculados. Permite atualização via Pull-To-Refresh,
/// edição de dados e exclusão do registro (restruto por permissão de Admin).
class DetalhesClientePage extends StatefulWidget {
  final Cliente cliente;
  final bool isAdmin;
  final String? orcamentoIdDestaque;

  const DetalhesClientePage({
    super.key,
    required this.cliente,
    this.isAdmin = true,
    this.orcamentoIdDestaque,
  });

  @override
  State<DetalhesClientePage> createState() => _DetalhesClientePageState();
}

class _DetalhesClientePageState extends State<DetalhesClientePage> {
  // [Repositório] Instância responsável pelo acesso a dados do cliente.
  final _clienteRepository = ClienteRepository();

  // [Estado Local] Armazena a instância atual do cliente e controla cor do tema visual.
  late Cliente _clienteExibido;
  late final Color _corTema;

  // [Chave Reativa] Utilizada para forçar a recarga do widget de histórico de orçamentos.
  Key _orcamentoHistoryKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _clienteExibido = widget.cliente;
    _corTema = widget.isAdmin
        ? AppColors.primaryAlternative
        : AppColors.primary;
  }

  /// [Objetivo] Formata o endereço completo do cliente para exibição.
  String get _enderecoFormatado {
    final comp = _clienteExibido.complemento;
    final temComplemento = comp != null && comp.trim().isNotEmpty;
    final sufixoComplemento = temComplemento ? ' ($comp)' : '';
    return '${_clienteExibido.rua}, ${_clienteExibido.numero}$sufixoComplemento - ${_clienteExibido.bairro}';
  }

  /// [Objetivo] Recarrega os dados do cliente e atualiza o histórico de orçamentos via Pull-To-Refresh.
  Future<void> _atualizarTela() async {
    if (_clienteExibido.id == null) return;

    try {
      final response = await _clienteRepository.buscarClientePorId(
        _clienteExibido.id!,
      );

      if (response != null && mounted) {
        setState(() {
          _clienteExibido = Cliente.fromMap(response);
          _orcamentoHistoryKey = UniqueKey();
        });
        AppFeedback.show(context, 'Dados atualizados.');
      }
    } catch (e) {
      if (!mounted) return;
      AppFeedback.show(
        context,
        ErrorHandler.mapearErro(e),
        type: FeedbackType.error,
      );
    }
  }

  /// [Objetivo] Executa a exclusão irreversível do cliente e seus registros vinculados após confirmação.
  Future<void> _excluirCliente() async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Excluir o cliente "${_clienteExibido.nome}"? Todos os orçamentos vinculados também serão removidos. Esta ação é irreversível.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Excluir',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;
    if (_clienteExibido.id == null) return;

    try {
      await _clienteRepository.excluirCliente(_clienteExibido.id!);

      if (!mounted) return;

      AppFeedback.show(
        context,
        'Cliente excluído com sucesso!',
        type: FeedbackType.success,
      );

      // [Navegação] Retorna para a tela anterior sinalizando a alteração na lista.
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      AppFeedback.show(
        context,
        ErrorHandler.mapearErro(e),
        type: FeedbackType.error,
      );
    }
  }

  /// [Objetivo] Copia um texto para a área de transferência do dispositivo.
  void _copiarParaClipboard(String texto, String item) {
    if (texto.trim().isEmpty) return;
    Clipboard.setData(ClipboardData(text: texto));
    AppFeedback.show(context, '$item copiado!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // [Barra de Título] Customizada com ações operacionais dinâmicas conforme perfil (Admin).
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40.0),
        child: AppBar(
          title: const Text("Detalhes do Cliente"),
          backgroundColor: _corTema,
          centerTitle: true,
          actions: widget.isAdmin
              ? [
                  IconButton(
                    icon: const Icon(AppIcons.editar),
                    tooltip: 'Editar Cliente',
                    onPressed: () async {
                      final Cliente? clienteAtualizado =
                          await Navigator.push<Cliente>(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditarClientePage(cliente: _clienteExibido),
                            ),
                          );

                      if (clienteAtualizado != null && mounted) {
                        setState(() => _clienteExibido = clienteAtualizado);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(AppIcons.excluir),
                    tooltip: 'Excluir Cliente',
                    onPressed: _excluirCliente,
                  ),
                ]
              : [],
        ),
      ),

      // [Ação Primária] Botão flutuante para abertura rápida de um novo orçamento.
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              onPressed: () async {
                final orcamentoAdicionado = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AdicionarOrcamento(cliente: _clienteExibido),
                  ),
                );

                if (orcamentoAdicionado == true && mounted) {
                  setState(() {
                    _orcamentoHistoryKey = UniqueKey();
                  });
                }
              },
              backgroundColor: _corTema,
              foregroundColor: AppColors.textPrimary,
              child: const Icon(AppIcons.adicionarOrcamento),
            )
          : null,

      // [Corpo] Conteúdo rolável suportando Pull-To-Refresh para sincronização.
      body: RefreshIndicator(
        onRefresh: _atualizarTela,
        color: _corTema,
        backgroundColor: AppColors.cardBackground,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppDimensions.spaceLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // [UI] Card principal de identificação do cliente.
              ClienteHeaderCard(cliente: _clienteExibido),
              const SizedBox(height: AppDimensions.spaceLarge),

              // [UI] Card com atalhos operacionais de comunicação (Telefone/WhatsApp).
              ClienteContatoCard(
                cliente: _clienteExibido,
                themeColor: _corTema,
                onCopyToClipboard: _copiarParaClipboard,
              ),

              // [UI] Exibição condicional do Endereço.
              if (_clienteExibido.rua.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spaceMedium),
                AppInfoRow(
                  icon: AppIcons.endereco,
                  label: "Endereço",
                  value: _enderecoFormatado,
                  onLongPress: () => _copiarParaClipboard(
                    '${_clienteExibido.rua}, ${_clienteExibido.numero}',
                    'Endereço',
                  ),
                  actionIcon: AppIcons.mapa,
                  actionIconColor: AppColors.primary,
                  onActionTap: () => LauncherUtils.abrirGoogleMapsPorEndereco(
                    rua: _clienteExibido.rua,
                    numero: _clienteExibido.numero,
                    bairro: _clienteExibido.bairro,
                  ),
                ),
              ],

              // [UI] Exibição condicional do CPF.
              if (_clienteExibido.cpf != null &&
                  _clienteExibido.cpf!.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spaceMedium),
                AppInfoRow(
                  icon: AppIcons.documento,
                  label: "CPF",
                  value: AppFormatters.cpf.maskText(_clienteExibido.cpf!),
                  onLongPress: () =>
                      _copiarParaClipboard(_clienteExibido.cpf!, 'CPF'),
                ),
              ],

              // [UI] Exibição condicional do CNPJ.
              if (_clienteExibido.cnpj != null &&
                  _clienteExibido.cnpj!.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spaceMedium),
                AppInfoRow(
                  icon: AppIcons.empresa,
                  label: "CNPJ",
                  value: AppFormatters.cnpj.maskText(_clienteExibido.cnpj!),
                  onLongPress: () =>
                      _copiarParaClipboard(_clienteExibido.cnpj!, 'CNPJ'),
                ),
              ],

              // [UI] Exibição condicional das Observações.
              if (_clienteExibido.observacao != null &&
                  _clienteExibido.observacao!.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spaceMedium),
                AppInfoRow(
                  icon: AppIcons.observacao,
                  label: "Observações",
                  value: _clienteExibido.observacao!,
                  isMultiline: true,
                ),
              ],

              const SizedBox(height: AppDimensions.spaceXLarge),

              // [UI] Histórico completo de orçamentos associados ao cliente.
              if (_clienteExibido.id != null)
                ClienteOrcamentosHistory(
                  key: _orcamentoHistoryKey,
                  clienteId: _clienteExibido.id!,
                  isAdmin: widget.isAdmin,
                  orcamentoIdDestaque: widget.orcamentoIdDestaque,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
