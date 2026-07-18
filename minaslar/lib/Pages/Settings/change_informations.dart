import '../../Core/Design/design_system.dart';
import '../../Core/Utils/formatters.dart';
import '../../Core/Widgets/widgets.dart';
import '../../Features/Modelos/usuario_model.dart';

/// Diálogo modal para a edição dos dados básicos do usuário logado.
///
/// [Uso] Este componente é exibido como uma janela sobreposta (Popup/Dialog)
/// quando o usuário decide atualizar seu perfil. Ele fornece um formulário
/// pré-preenchido para alteração de nome e telefone, gerenciando a validação local
/// dos campos.
class ChangeInformationsDialog extends StatefulWidget {
  /// O modelo do usuário contendo os dados atuais antes da edição.
  final Usuario currentUser;

  const ChangeInformationsDialog({super.key, required this.currentUser});

  @override
  State<ChangeInformationsDialog> createState() =>
      _ChangeInformationsDialogState();
}

/// Estado que gerencia o formulário de edição e os controladores de texto.
///
/// [Uso] Controla o ciclo de vida dos campos de entrada (`TextEditingController`),
/// aplica as máscaras visuais nos dados iniciais e manipula o evento de salvamento,
/// retornando as informações tratadas para a tela que invocou o diálogo.
class _ChangeInformationsDialogState extends State<ChangeInformationsDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _telefoneController;

  @override
  void initState() {
    super.initState();
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

  /// Valida o formulário e retorna os dados limpos para quem abriu o modal.
  ///
  /// [Uso] Se o formulário passar nas validações visuais de integridade,
  /// este método remove as máscaras do telefone e fecha a janela, enviando de volta
  /// um dicionário (`Map<String, String>`) com as novas strings limpas.
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
              validator: (v) => v!.length < 15 ? 'Telefone incompleto' : null,
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
