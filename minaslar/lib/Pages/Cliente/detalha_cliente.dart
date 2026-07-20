import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../Core/Design/design_system.dart';
import '../../Core/Errors/errors.dart';
import '../../Core/Services/communication.dart';
import '../../Core/Utils/formatters.dart';
import '../../Core/Widgets/widgets.dart';
import '../../Features/Modelos/cliente_model.dart';
import 'edita_cliente.dart';

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

  @override
  void initState() {
    super.initState();
    _clienteExibido = widget.cliente;
    corTema = widget.isAdmin ? AppColors.primaryAlternative : AppColors.primary;
  }

  // 1. Atualização defensiva com fallback e uso de maybeSingle()
  Future<void> _atualizarTela() async {
    if (_clienteExibido.id == null) return;

    try {
      dynamic response;
      try {
        // Tenta buscar mantendo o padrão com JOIN do último orçamento
        response = await Supabase.instance.client
            .from('clientes')
            .select('*, orcamentos!ultimo_orcamento_id(data_pega)')
            .eq('id', _clienteExibido.id!)
            .maybeSingle();
      } catch (_) {
        // Fallback caso a relação/tabela orcamentos ainda não exista
        response = await Supabase.instance.client
            .from('clientes')
            .select()
            .eq('id', _clienteExibido.id!)
            .maybeSingle();
      }

      if (response != null && mounted) {
        setState(() => _clienteExibido = Cliente.fromMap(response));
        AppFeedback.show(context, 'Dados atualizados.');
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.show(
          context,
          ErrorHandler.mapearErro(e),
          type: FeedbackType.error,
        );
      }
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

    try {
      await Supabase.instance.client
          .from('clientes')
          .delete()
          .eq('id', _clienteExibido.id!);

      if (mounted) {
        AppFeedback.show(
          context,
          'Cliente excluído com sucesso!',
          type: FeedbackType.success,
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.show(
          context,
          ErrorHandler.mapearErro(e),
          type: FeedbackType.error,
        );
      }
    }
  }

  void _copiarParaClipboard(String texto, String item) {
    if (texto.isEmpty) return;
    Clipboard.setData(ClipboardData(text: texto));
    AppFeedback.show(context, '$item copiado!');
  }

  @override
  Widget build(BuildContext context) {
    final isProblematico = _clienteExibido.clienteProblematico;
    final statusColor = isProblematico ? AppColors.error : AppColors.primary;

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
              _buildHeaderCard(statusColor),
              const SizedBox(height: AppDimensions.spaceLarge),
              _buildContatoCard(),
              if (_clienteExibido.rua.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spaceMedium),
                _buildInfoRow(
                  icon: Icons.location_on_outlined,
                  label: "Endereço",
                  value:
                      '${_clienteExibido.rua}, ${_clienteExibido.numero}${_clienteExibido.complemento != null && _clienteExibido.complemento!.isNotEmpty ? ' (${_clienteExibido.complemento})' : ''} - ${_clienteExibido.bairro}',
                  onLongPress: () => _copiarParaClipboard(
                    '${_clienteExibido.rua}, ${_clienteExibido.numero}',
                    'Endereço',
                  ),
                  actionIcon: Icons.map_outlined,
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
                _buildInfoRow(
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
                _buildInfoRow(
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
                _buildInfoRow(
                  icon: Icons.comment_outlined,
                  label: "Observações",
                  value: _clienteExibido.observacao!,
                  isMultiline: true,
                ),
              ],
              const SizedBox(height: AppDimensions.spaceXLarge),
              _buildOrcamentosSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceLarge),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border(left: BorderSide(color: statusColor, width: 5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: statusColor.withOpacity(0.15),
            child: Icon(AppIcons.clientes, color: statusColor, size: 28),
          ),
          const SizedBox(width: AppDimensions.spaceMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_clienteExibido.nome, style: AppTextStyles.titleMedium),
                if (_clienteExibido.clienteProblematico) ...[
                  const SizedBox(height: AppDimensions.spaceXSmall),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSmall,
                      ),
                      border: Border.all(
                        color: AppColors.error.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      "CLIENTE PROBLEMÁTICO",
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.error,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContatoCard() {
    return Material(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      child: InkWell(
        onLongPress: () =>
            _copiarParaClipboard(_clienteExibido.telefone, 'Telefone'),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceLarge,
            vertical: AppDimensions.spaceSmall,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Icon(
                AppIcons.telefone,
                color: corTema,
                size: AppDimensions.iconSize,
              ),
              const SizedBox(width: AppDimensions.spaceMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("TELEFONE", style: AppTextStyles.overline),
                    const SizedBox(height: AppDimensions.spaceXSmall),
                    Text(
                      AppFormatters.telefone.maskText(_clienteExibido.telefone),
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () =>
                    LauncherUtils.fazerLigacao(_clienteExibido.telefone),
                icon: const Icon(Icons.phone),
                tooltip: 'Ligar',
              ),
              IconButton(
                onPressed: () =>
                    LauncherUtils.abrirWhatsApp(_clienteExibido.telefone),
                icon: const Icon(AppIcons.chat, color: AppColors.success),
                tooltip: 'WhatsApp',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isMultiline = false,
    VoidCallback? onLongPress,
    IconData? actionIcon,
    VoidCallback? onActionTap,
  }) {
    return Material(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      child: InkWell(
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.spaceLarge),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            crossAxisAlignment: isMultiline
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: AppColors.textDisabled,
                size: AppDimensions.iconSize,
              ),
              const SizedBox(width: AppDimensions.spaceMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label.toUpperCase(), style: AppTextStyles.overline),
                    const SizedBox(height: AppDimensions.spaceXSmall),
                    Text(
                      value,
                      style: AppTextStyles.bodyMedium.copyWith(height: 1.4),
                    ),
                  ],
                ),
              ),
              if (actionIcon != null)
                IconButton(
                  onPressed: onActionTap,
                  icon: Icon(actionIcon, color: AppColors.primary),
                  tooltip: 'Abrir no Mapa',
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrcamentosSection() {
    if (_clienteExibido.id == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(
          icon: Icons.history,
          title: 'HISTÓRICO DE ORÇAMENTOS',
        ),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: Supabase.instance.client
              .from('orcamentos')
              .select()
              .eq('cliente_id', _clienteExibido.id!)
              .order('data_pega', ascending: false),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Exibe lista vazia de forma graciosa caso ocorra erro (ex: tabela ainda não criada)
            if (snapshot.hasError) {
              return const AppEmptyListIndicator(
                message: "Nenhum orçamento registrado para este cliente.",
                icon: Icons.receipt_long_outlined,
              );
            }

            final orcamentos = snapshot.data ?? [];

            if (orcamentos.isEmpty) {
              return const AppEmptyListIndicator(
                message: "Nenhum orçamento registrado para este cliente.",
                icon: Icons.receipt_long_outlined,
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orcamentos.length,
              itemBuilder: (context, index) {
                return _buildOrcamentoItem(orcamentos[index], orcamentos);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildOrcamentoItem(
    Map<String, dynamic> orcamento,
    List<Map<String, dynamic>> lista,
  ) {
    final titulo = orcamento['titulo'] ?? 'Serviço';
    final valor = orcamento['valor'];
    final dataPega = DateTime.tryParse(orcamento['data_pega'] ?? '');

    final bool isUltimo = lista.indexOf(orcamento) == 0;
    final bool isDestaque = orcamento['id'] == widget.orcamentoIdDestaque;
    final Color statusColor = isDestaque
        ? AppColors.adminColor
        : isUltimo
        ? AppColors.success
        : AppColors.textDisabled;

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceSmall),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        side: isUltimo || isDestaque
            ? BorderSide(color: statusColor.withOpacity(0.7), width: 1.5)
            : const BorderSide(color: AppColors.borderLight),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spaceSmall,
          horizontal: AppDimensions.spaceLarge,
        ),
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isDestaque ? Icons.star : Icons.build_circle_outlined,
              color: statusColor,
            ),
          ],
        ),
        title: Text(titulo, style: AppTextStyles.bodyMedium),
        subtitle: Row(
          children: [
            if (dataPega != null)
              Text(
                DateFormat('dd/MM/yyyy').format(dataPega),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textDisabled,
                ),
              ),
            const Spacer(),
            if (valor != null)
              Text(
                NumberFormat.currency(
                  locale: 'pt_BR',
                  symbol: 'R\$',
                ).format(valor),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.adminColor,
                ),
              ),
          ],
        ),
        trailing: widget.isAdmin
            ? PopupMenuButton<String>(
                onSelected: (choice) {
                  // TODO: Implementar edição e exclusão de orçamento
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'editar', child: Text('Editar')),
                  const PopupMenuItem(value: 'excluir', child: Text('Excluir')),
                ],
              )
            : null,
      ),
    );
  }
}
