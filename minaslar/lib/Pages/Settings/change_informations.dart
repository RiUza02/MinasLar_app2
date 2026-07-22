import '../../Core/Design/design_system.dart';
import '../../Core/Utils/formatters.dart';
import '../../Core/Widgets/widgets.dart';
import '../../Features/Modelos/usuario_model.dart';

// **[Propósito]** Componente modal (dialog) encapsulado para visualização e edição rápida dos dados de perfil do usuário autenticado.
// **[Como usar]** final result = await showDialog<Map<String, dynamic>>(context: context, builder: (_) => ChangeInformationsDialog(currentUser: usuario));
class ChangeInformationsDialog extends StatefulWidget {
  final Usuario currentUser;

  const ChangeInformationsDialog({super.key, required this.currentUser});

  @override
  State<ChangeInformationsDialog> createState() =>
      _ChangeInformationsDialogState();
}

class _ChangeInformationsDialogState extends State<ChangeInformationsDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _telefoneController;

  @override
  void initState() {
    super.initState();
    // **[Inicialização de Dados]** Carrega as informações atuais do usuário e aplica a máscara visual de telefone logo na abertura do modal
    _nomeController = TextEditingController(text: widget.currentUser.nome);
    _telefoneController = TextEditingController(
      text: AppFormatters.telefone.maskText(widget.currentUser.telefone),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  // **[Ação de Salvamento]** Valida os inputs, sanitiza (unmask) os dados formatados e os devolve para a tela chamadora via Navigator.pop
  void _saveAndPop() {
    if (_formKey.currentState!.validate()) {
      final result = {
        'nome': _nomeController.text.trim(),
        'telefone': AppFormatters.telefone.unmaskText(_telefoneController.text),
      };
      Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      title: const Text('Alterar Meus Dados'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // **[Campo: Nome]** Validação simples para garantir que o usuário não salve o nome em branco
            AppTextField(
              controller: _nomeController,
              label: 'Nome de Usuário',
              icon: AppIcons.nome,
              validator: (v) => v!.trim().isEmpty ? 'Informe o nome' : null,
            ),
            const SizedBox(height: AppDimensions.spaceLarge),

            // **[Campo: Telefone]** Integra formatação em tempo real e regra de negócio para telefones fixos (10 dígitos) ou celulares (11 dígitos)
            AppTextField(
              controller: _telefoneController,
              label: 'Meu Telefone',
              icon: AppIcons.telefone,
              keyboardType: TextInputType.phone,
              inputFormatters: [AppFormatters.telefone],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Informe o telefone';
                final unmasked = AppFormatters.telefone.unmaskText(v);
                if (unmasked.length != 10 && unmasked.length != 11) {
                  return 'O telefone deve ter 10 ou 11 dígitos.';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCELAR'),
        ),
        ElevatedButton(onPressed: _saveAndPop, child: const Text('SALVAR')),
      ],
    );
  }
}
