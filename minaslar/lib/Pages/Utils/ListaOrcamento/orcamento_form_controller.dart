import 'package:flutter/material.dart';
import '../../../Features/Modelos/orcamento_model.dart';

/// Define um contrato para os controllers de formulário de orçamento,
/// permitindo que os widgets de UI sejam genéricos e reutilizáveis.
abstract class OrcamentoFormController extends ChangeNotifier {
  // FORM STATE
  GlobalKey<FormState> get formKey;
  TextEditingController get tituloController;
  TextEditingController get descricaoController;
  TextEditingController get valorController;

  // DATA STATE
  DateTime get dataPega;
  DateTime? get dataEntrega;
  Turno get horarioSelecionado;
  bool get foiEntregue;
  bool get ehRetorno;
  bool get ehUrgente;
  bool get isLoading;

  // UI LOGIC
  void setHorario(Turno novoHorario);
  void setStatus({bool? entregue, bool? retorno, bool? urgente});
  void setData(DateTime data, {required bool isEntrega});
  void limparDataEntrega();
}
