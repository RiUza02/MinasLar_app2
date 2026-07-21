import 'dart:async';
import '../../Core/Design/design_system.dart';
import '../../Core/Widgets/widgets.dart' hide OrcamentoCard;
import '../../Core/Errors/errors.dart';
import '../../Features/Modelos/cliente_model.dart';
import '../../Features/Modelos/orcamento_model.dart';
import '../../Features/Repositorios/orcamento_repository.dart';
import '../Utils/ListaOrcamento/seleciona_cliente.dart';
import '../Orcamento/cria_orcamento.dart';
import '../Orcamento/detalha_orcamento.dart';
import '../Utils/ListaOrcamento/orcamento_list_header.dart';
import '../Utils/ListaOrcamento/orcamento_card.dart';

enum OrcamentoSortColumn { dataRecente, valor, status }

class ListaOrcamentoPage extends StatefulWidget {
  final bool isAdmin;
  const ListaOrcamentoPage({super.key, required this.isAdmin});

  @override
  State<ListaOrcamentoPage> createState() => _ListaOrcamentoPageState();
}

class _ListaOrcamentoPageState extends State<ListaOrcamentoPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _repository = OrcamentoRepository();
  Timer? _debounce;

  List<Orcamento> _orcamentos = [];
  int _page = 1;
  final int _pageSize = 10;
  bool _isLoading = true;
  bool _isLoadMore = false;
  bool _hasMore = true;
  String? _error;

  String _searchTerm = '';
  OrcamentoSortColumn _sortColumn = OrcamentoSortColumn.dataRecente;
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _loadOrcamentos();
    _setupScrollListener();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (_hasMore && !_isLoadMore && !_isLoading) {
          _loadOrcamentos(isPaginating: true);
        }
      }
    });
  }

  Future<void> _loadOrcamentos({bool isPaginating = false}) async {
    if (!mounted) return;
    setState(() {
      if (isPaginating) {
        _isLoadMore = true;
      } else {
        _isLoading = true;
      }
      _error = null;
    });

    try {
      final newOrcamentos = await _repository.buscarOrcamentosPaginados(
        page: _page,
        pageSize: _pageSize,
        termo: _searchTerm,
        sortColumn: _sortColumn,
        ascending: _sortAscending,
      );

      if (mounted) {
        setState(() {
          if (isPaginating) {
            _orcamentos.addAll(newOrcamentos);
          } else {
            _orcamentos = newOrcamentos;
          }
          _page++;
          _hasMore = newOrcamentos.length == _pageSize;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = ErrorHandler.mapearErro(e));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadMore = false;
        });
      }
    }
  }

  Future<void> _resetAndLoad() async {
    setState(() {
      _page = 1;
      _orcamentos = [];
      _hasMore = true;
    });
    await _loadOrcamentos();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (_searchTerm != _searchController.text.trim()) {
        setState(() => _searchTerm = _searchController.text.trim());
        _resetAndLoad();
      }
    });
  }

  void _onSortChanged(OrcamentoSortColumn? newSort) {
    if (newSort == null) return;
    setState(() {
      if (newSort == _sortColumn) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = newSort;
        if (newSort == OrcamentoSortColumn.dataRecente ||
            newSort == OrcamentoSortColumn.valor) {
          _sortAscending = false;
        } else {
          _sortAscending = true;
        }
      }
    });
    _resetAndLoad();
  }

  Future<void> _abrirNovoOrcamento() async {
    final Cliente? clienteEscolhido = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SelecionaClientePage()),
    );

    if (clienteEscolhido == null || !mounted) return;

    final bool? orcamentoAdicionado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdicionarOrcamento(cliente: clienteEscolhido),
      ),
    );

    if (orcamentoAdicionado == true) _resetAndLoad();
  }

  Future<void> _navegarDetalhes(Orcamento orcamento) async {
    final orcamentoMap = orcamento.toMap();
    orcamentoMap['id'] = orcamento.id;
    if (orcamento.cliente != null) {
      orcamentoMap['clientes'] = orcamento.cliente!.toMap();
    }

    final bool? foiModificado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhesOrcamento(
          orcamentoInicial: orcamentoMap,
          isAdmin: widget.isAdmin,
        ),
      ),
    );
    if (foiModificado == true) _resetAndLoad();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              heroTag: 'btnAddOrcamento',
              onPressed: _abrirNovoOrcamento,
              backgroundColor: AppColors.primaryAlternative,
              foregroundColor: AppColors.textPrimary,
              child: const Icon(AppIcons.adicionarOrcamento),
            )
          : null,
      body: Column(
        children: [
          OrcamentoListHeader(
            searchController: _searchController,
            sortColumn: _sortColumn,
            sortAscending: _sortAscending,
            onSortChanged: _onSortChanged,
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _orcamentos.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return AppErrorView(
        message: _error!,
        buttonText: 'Tentar Novamente',
        onTryAgain: _resetAndLoad,
        icon: Icons.cloud_off,
      );
    }

    if (_orcamentos.isEmpty) {
      return RefreshIndicator(
        onRefresh: _resetAndLoad,
        color: AppColors.primary,
        backgroundColor: AppColors.cardBackground,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                height: constraints.maxHeight,
                alignment: Alignment.center,
                child: AppEmptyListIndicator(
                  message: _searchTerm.isNotEmpty
                      ? 'Nenhum orçamento encontrado para "$_searchTerm"'
                      : 'Nenhum orçamento cadastrado.',
                  icon: AppIcons.orcamentos,
                ),
              ),
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _resetAndLoad,
      color: AppColors.primary,
      backgroundColor: AppColors.cardBackground,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.spaceLarge,
          AppDimensions.spaceSmall,
          AppDimensions.spaceLarge,
          90,
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _orcamentos.length + (_isLoadMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _orcamentos.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }
          final orcamento = _orcamentos[index];
          return OrcamentoCard(
            orcamento: orcamento,
            isAdmin: widget.isAdmin,
            onTap: () => _navegarDetalhes(orcamento),
          );
        },
      ),
    );
  }
}
