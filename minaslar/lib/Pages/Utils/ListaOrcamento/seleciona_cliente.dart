import 'dart:async';
import '../../../Core/Design/design_system.dart';
import '../../../Core/Widgets/widgets.dart';
import '../../../Core/Errors/errors.dart';
import '../../../Features/Modelos/cliente_model.dart';
import '../../../Features/Repositorios/cliente_repository.dart';
import '../ListaCliente/cliente_list_header.dart';
import '../../Cliente/cria_cliente.dart';
import '../../HomePage/lista_cliente.dart';

class SelecionaClientePage extends StatefulWidget {
  const SelecionaClientePage({super.key});

  @override
  State<SelecionaClientePage> createState() => _SelecionaClientePageState();
}

class _SelecionaClientePageState extends State<SelecionaClientePage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _repository = ClienteRepository();
  Timer? _debounce;

  List<Cliente> _clientes = [];
  int _page = 1;
  final int _pageSize = 15;
  bool _isLoading = true;
  bool _isLoadMore = false;
  bool _hasMore = true;
  String? _error;

  String _searchTerm = '';
  ClienteSortColumn _sortColumn = ClienteSortColumn.nome;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _loadClientes();
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
          _loadClientes(isPaginating: true);
        }
      }
    });
  }

  Future<void> _loadClientes({bool isPaginating = false}) async {
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
      final newClientes = await _repository.buscarClientesPaginados(
        page: _page,
        pageSize: _pageSize,
        termo: _searchTerm,
        sortColumn: _sortColumn,
        ascending: _sortAscending,
      );
      if (mounted) {
        setState(() {
          if (isPaginating) {
            _clientes.addAll(newClientes);
          } else {
            _clientes = newClientes;
          }
          _page++;
          _hasMore = newClientes.length == _pageSize;
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
      _clientes = [];
      _hasMore = true;
    });
    await _loadClientes();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (_searchTerm != _searchController.text.trim()) {
        setState(() => _searchTerm = _searchController.text.trim());
        _resetAndLoad();
      }
    });
  }

  void _onSortChanged(ClienteSortColumn? newSort) {
    if (newSort == null) return;
    setState(() {
      if (newSort == _sortColumn) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = newSort;
        _sortAscending = _sortColumn != ClienteSortColumn.ultimoAtendimento;
      }
    });
    _resetAndLoad();
  }

  Future<void> _abrirNovoCliente() async {
    final bool? clienteAdicionado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdicionarClientePage()),
    );
    if (clienteAdicionado == true && mounted) {
      _resetAndLoad();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40.0),
        child: AppBar(
          title: const Text("Selecionar Cliente"),
          backgroundColor: AppColors.primaryAlternative,
          centerTitle: true,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'btnAddClienteSelecao',
        onPressed: _abrirNovoCliente,
        backgroundColor: AppColors.primaryAlternative,
        foregroundColor: AppColors.textPrimary,
        child: const Icon(AppIcons.add),
      ),
      body: Column(
        children: [
          ClienteListHeader(
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
    if (_isLoading && _clientes.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_error != null) {
      return AppErrorView(
        message: _error!,
        buttonText: 'Tentar Novamente',
        onTryAgain: _resetAndLoad,
      );
    }
    if (_clientes.isEmpty) {
      return AppEmptyListIndicator(
        message: _searchTerm.isNotEmpty
            ? 'Nenhum cliente encontrado para "$_searchTerm"'
            : 'Nenhum cliente cadastrado.',
        icon: AppIcons.clientes,
      );
    }
    return RefreshIndicator(
      onRefresh: _resetAndLoad,
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
        itemCount: _clientes.length + (_isLoadMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _clientes.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }
          final cliente = _clientes[index];
          return ClienteCard(
            cliente: cliente,
            onTap: () => Navigator.of(
              context,
            ).pop(cliente), // Retorna o cliente selecionado
          );
        },
      ),
    );
  }
}
