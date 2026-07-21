import 'package:flutter/foundation.dart';

import '../../../Core/Errors/errors.dart';
import '../../../Features/Modelos/orcamento_model.dart';
import '../../../Features/Repositorios/orcamento_repository.dart';

class DetalhesOrcamentoController extends ChangeNotifier {
  final OrcamentoRepository _repository;
  final String _orcamentoId;

  DetalhesOrcamentoController({
    required OrcamentoRepository repository,
    required Orcamento orcamentoInicial,
  }) : _repository = repository,
       _orcamentoId = orcamentoInicial.id!,
       _orcamento = orcamentoInicial;

  // ==================================================
  // STATE
  // ==================================================
  late Orcamento _orcamento;
  Orcamento get orcamento => _orcamento;

  bool _isLoading = true; // Inicia como true para o carregamento inicial
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // ==================================================
  // LOGIC
  // ==================================================

  Future<void> carregarDetalhes() async {
    _setLoading(true);
    _error = null;

    try {
      // Busca a versão mais recente do orçamento no banco
      _orcamento = await _repository.buscarOrcamentoPorId(_orcamentoId);
    } catch (e) {
      _error = ErrorHandler.mapearErro(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> alterarStatusEntrega() async {
    _setLoading(true);
    String? errorMessage;

    try {
      // Cria uma cópia com o status invertido e salva usando o upsert do repositório
      final orcamentoAtualizado = _orcamento.copyWith(
        entregue: !_orcamento.entregue,
      );
      await _repository.salvarOrcamento(orcamentoAtualizado);

      // Atualiza o estado local para uma resposta visual imediata
      _orcamento = orcamentoAtualizado;
    } catch (e) {
      errorMessage = ErrorHandler.mapearErro(e);
    } finally {
      // Garante a consistência recarregando os dados do servidor
      await carregarDetalhes();
    }
    return errorMessage;
  }

  Future<String?> excluirOrcamento() async {
    _setLoading(true);
    String? errorMessage;
    try {
      await _repository.excluirOrcamento(_orcamentoId);
    } catch (e) {
      errorMessage = ErrorHandler.mapearErro(e);
    } finally {
      // Não precisa notificar listeners aqui, pois a tela será fechada
      _isLoading = false;
    }
    return errorMessage;
  }

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }
}
