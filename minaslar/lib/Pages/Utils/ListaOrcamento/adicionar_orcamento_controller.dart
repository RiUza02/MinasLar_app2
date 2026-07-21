import 'package:flutter/material.dart';

import '../../../Core/Errors/errors.dart';
import '../../../Features/Modelos/cliente_model.dart';
import '../../../Features/Modelos/orcamento_model.dart';
import '../../../Features/Repositorios/orcamento_repository.dart';
import 'orcamento_form_controller.dart';

class AdicionarOrcamentoController extends OrcamentoFormController {
  final OrcamentoRepository _repository;
  final Cliente cliente;

  AdicionarOrcamentoController({
    required this.cliente,
    required OrcamentoRepository repository,
    DateTime? dataSelecionada,
  }) : _repository = repository {
    _dataPega = dataSelecionada ?? DateTime.now();
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

  Turno _horarioSelecionado = Turno.manha;
  @override
  Turno get horarioSelecionado => _horarioSelecionado;

  bool _foiEntregue = false;
  @override
  bool get foiEntregue => _foiEntregue;

  bool _ehRetorno = false;
  @override
  bool get ehRetorno => _ehRetorno;

  bool _ehUrgente = false;
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
  Future<String?> salvarOrcamento() async {
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

      if (cliente.id == null) {
        return "ID do cliente não encontrado. Não é possível salvar o orçamento.";
      }

      final novoOrcamento = Orcamento(
        clienteId: cliente.id!,
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

      await _repository.salvarOrcamento(novoOrcamento);
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
