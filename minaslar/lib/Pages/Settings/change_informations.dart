import '../../Core/Design/design_system.dart';
import '../../Core/Utils/formatters.dart';
import '../../Core/Widgets/widgets.dart';
import '../../Features/Modelos/usuario_model.dart';

/// [uso]: Diálogo modal para edição dos dados básicos (nome e telefone) do usuário logado.
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
    // Inicialização dos controllers com os dados atuais e aplicação da máscara no telefone
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

  /// Valida o formulário, remove as máscaras e retorna os dados atualizados
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
            AppTextField(
              controller: _nomeController,
              label: 'Nome de Usuário',
              icon: AppIcons.nome,
              validator: (v) => v!.trim().isEmpty ? 'Informe o nome' : null,
            ),
            const SizedBox(height: AppDimensions.spaceLarge),
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
