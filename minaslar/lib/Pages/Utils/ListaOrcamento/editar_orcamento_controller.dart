import 'package:flutter/material.dart';

import '../../../Core/Errors/errors.dart';
import '../../../Features/Modelos/orcamento_model.dart';
import '../../../Features/Repositorios/orcamento_repository.dart';
import 'orcamento_form_controller.dart';

class EditarOrcamentoController extends OrcamentoFormController {
  final OrcamentoRepository _repository;
  final Orcamento _orcamentoOriginal;

  EditarOrcamentoController({
    required OrcamentoRepository repository,
    required Orcamento orcamento,
  }) : _repository = repository,
       _orcamentoOriginal = orcamento {
    // Initialize form state from the original budget
    tituloController.text = _orcamentoOriginal.titulo;
    descricaoController.text = _orcamentoOriginal.descricao ?? '';
    valorController.text = _orcamentoOriginal.valor?.toString() ?? '';
    _dataPega = _orcamentoOriginal.dataPega;
    _dataEntrega = _orcamentoOriginal.dataEntrega;
    _horarioSelecionado = _orcamentoOriginal.horarioDoDia;
    _foiEntregue = _orcamentoOriginal.entregue;
    _ehRetorno = _orcamentoOriginal.ehRetorno;
    _ehUrgente = _orcamentoOriginal.ehUrgente;
  }

  // ==================================================
  // FORM STATE
  // ==================================================
  @override
  final formKey = GlobalKey<FormState>();
  @override
  final tituloController = TextEditingController();
  @override
  final descricaoController = TextEditingController();
  @override
  final valorController = TextEditingController();

  late DateTime _dataPega;
  @override
  DateTime get dataPega => _dataPega;

  DateTime? _dataEntrega;
  @override
  DateTime? get dataEntrega => _dataEntrega;

  late Turno _horarioSelecionado;
  @override
  Turno get horarioSelecionado => _horarioSelecionado;

  late bool _foiEntregue;
  @override
  bool get foiEntregue => _foiEntregue;

  late bool _ehRetorno;
  @override
  bool get ehRetorno => _ehRetorno;

  late bool _ehUrgente;
  @override
  bool get ehUrgente => _ehUrgente;

  bool _isLoading = false;
  @override
  bool get isLoading => _isLoading;

  // ==================================================
  // UI LOGIC
  // ==================================================
  @override
  void setHorario(Turno novoHorario) {
    if (_horarioSelecionado != novoHorario) {
      _horarioSelecionado = novoHorario;
      notifyListeners();
    }
  }

  @override
  void setStatus({bool? entregue, bool? retorno, bool? urgente}) {
    _foiEntregue = entregue ?? _foiEntregue;
    _ehRetorno = retorno ?? _ehRetorno;
    _ehUrgente = urgente ?? _ehUrgente;
    notifyListeners();
  }

  @override
  void setData(DateTime data, {required bool isEntrega}) {
    if (isEntrega) {
      if (_dataEntrega != data) {
        _dataEntrega = data;
        notifyListeners();
      }
    } else {
      if (_dataPega != data) {
        _dataPega = data;
        if (_dataEntrega != null && _dataEntrega!.isBefore(data)) {
          _dataEntrega = null;
        }
        notifyListeners();
      }
    }
  }

  @override
  void limparDataEntrega() {
    if (_dataEntrega != null) {
      _dataEntrega = null;
      notifyListeners();
    }
  }

  // ==================================================
  // BUSINESS LOGIC & PERSISTENCE
  // ==================================================
  Future<String?> salvarEdicao() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return null;
    }

    if (_dataEntrega != null &&
        _dataEntrega!.isBefore(DateUtils.dateOnly(_dataPega))) {
      return 'A data de entrega não pode ser anterior à de entrada.';
    }

    _setLoading(true);

    try {
      final String valorTexto = valorController.text
          .replaceAll(',', '.')
          .trim();
      final double? valorFinal = valorTexto.isEmpty
          ? null
          : double.tryParse(valorTexto);

      final orcamentoAtualizado = _orcamentoOriginal.copyWith(
        titulo: tituloController.text,
        descricao: descricaoController.text,
        dataPega: _dataPega,
        dataEntrega: _dataEntrega,
        valor: valorFinal,
        horarioDoDia: _horarioSelecionado,
        entregue: _foiEntregue,
        ehRetorno: _ehRetorno,
        ehUrgente: _ehUrgente,
      );

      await _repository.salvarOrcamento(orcamentoAtualizado);
      return null; // Success
    } catch (e) {
      return ErrorHandler.mapearErro(e);
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    tituloController.dispose();
    descricaoController.dispose();
    valorController.dispose();
    super.dispose();
  }
}
