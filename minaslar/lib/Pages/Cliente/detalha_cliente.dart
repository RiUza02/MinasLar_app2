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

// O widget AppInfoRow foi criado em 'lib/Core/Widgets/app_info_row.dart'
// e exportado em 'lib/Core/Widgets/widgets.dart' para que este import funcione.

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
  late Cliente _clienteExibido;
  late final Color corTema;
  final _clienteRepository = ClienteRepository();

  @override
  void initState() {
    super.initState();
    _clienteExibido = widget.cliente;
    corTema = widget.isAdmin ? AppColors.primaryAlternative : AppColors.primary;
  }

  Future<void> _atualizarTela() async {
    if (_clienteExibido.id == null) return;

    try {
      final response = await _clienteRepository.buscarClientePorId(
        _clienteExibido.id!,
      );

      if (response != null && mounted) {
        setState(() => _clienteExibido = Cliente.fromMap(response));
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

      if (mounted) {
        AppFeedback.show(
          context,
          'Cliente excluído com sucesso!',
          type: FeedbackType.success,
        );
        Navigator.of(context).pop(true);
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

  void _copiarParaClipboard(String texto, String item) {
    if (texto.isEmpty) return;
    Clipboard.setData(ClipboardData(text: texto));
    AppFeedback.show(context, '$item copiado!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40.0),
        child: AppBar(
          title: const Text("Detalhes do Cliente"),
          backgroundColor: corTema,
          centerTitle: true,
          actions: widget.isAdmin
              ? [
                  IconButton(
                    icon: const Icon(Icons.edit),
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
                    icon: const Icon(Icons.delete_forever_outlined),
                    tooltip: 'Excluir Cliente',
                    onPressed: _excluirCliente,
                  ),
                ]
              : [],
        ),
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              onPressed: () {
                // TODO: Navegar para AdicionarOrcamentoPage
              },
              backgroundColor: corTema,
              child: const Icon(Icons.add_comment_outlined),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _atualizarTela,
        color: corTema,
        backgroundColor: AppColors.cardBackground,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppDimensions.spaceLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClienteHeaderCard(cliente: _clienteExibido),
              const SizedBox(height: AppDimensions.spaceLarge),
              ClienteContatoCard(
                cliente: _clienteExibido,
                themeColor: corTema,
                onCopyToClipboard: _copiarParaClipboard,
              ),
              if (_clienteExibido.rua.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spaceMedium),
                AppInfoRow(
                  icon: Icons.location_on_outlined,
                  label: "Endereço",
                  value:
                      '${_clienteExibido.rua}, ${_clienteExibido.numero}${_clienteExibido.complemento != null && _clienteExibido.complemento!.isNotEmpty ? ' (${_clienteExibido.complemento})' : ''} - ${_clienteExibido.bairro}',
                  onLongPress: () => _copiarParaClipboard(
                    '${_clienteExibido.rua}, ${_clienteExibido.numero}',
                    'Endereço',
                  ),
                  actionIcon: Icons.map_outlined,
                  actionIconColor: corTema,
                  onActionTap: () => LauncherUtils.abrirGoogleMapsPorEndereco(
                    rua: _clienteExibido.rua,
                    numero: _clienteExibido.numero,
                    bairro: _clienteExibido.bairro,
                  ),
                ),
              ],
              if (_clienteExibido.cpf != null &&
                  _clienteExibido.cpf!.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spaceMedium),
                AppInfoRow(
                  icon: Icons.badge_outlined,
                  label: "CPF",
                  value: AppFormatters.cpf.maskText(_clienteExibido.cpf!),
                  onLongPress: () =>
                      _copiarParaClipboard(_clienteExibido.cpf!, 'CPF'),
                ),
              ],
              if (_clienteExibido.cnpj != null &&
                  _clienteExibido.cnpj!.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spaceMedium),
                AppInfoRow(
                  icon: Icons.domain,
                  label: "CNPJ",
                  value: AppFormatters.cnpj.maskText(_clienteExibido.cnpj!),
                  onLongPress: () =>
                      _copiarParaClipboard(_clienteExibido.cnpj!, 'CNPJ'),
                ),
              ],
              if (_clienteExibido.observacao != null &&
                  _clienteExibido.observacao!.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spaceMedium),
                AppInfoRow(
                  icon: Icons.comment_outlined,
                  label: "Observações",
                  value: _clienteExibido.observacao!,
                  isMultiline: true,
                ),
              ],
              const SizedBox(height: AppDimensions.spaceXLarge),
              if (_clienteExibido.id != null)
                ClienteOrcamentosHistory(
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
