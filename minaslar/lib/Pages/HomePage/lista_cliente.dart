import 'dart:async';
import '../../Core/Design/design_system.dart';
import '../../Core/Widgets/widgets.dart';
import '../../Core/Errors/errors.dart';
import '../../Features/Modelos/cliente_model.dart';
import '../../Features/Repositorios/cliente_repository.dart';
import '../Cliente/cria_cliente.dart';
import '../Cliente/detalha_cliente.dart';
import '../Utils/ListaCliente/cliente_list_header.dart';

// Colunas disponíveis para ordenação da lista.
enum ClienteSortColumn { ultimoAtendimento, nome, rua, bairro }

// **[Propósito]** Tela principal de listagem paginada e busca de clientes. Possui debounce na pesquisa, paginação infinita e ordenação.
// **[Como usar]** Empregada como uma aba da navegação principal, repassando a permissão do usuário logado: ListaClientePage(isAdmin: usuario.isAdmin)
class ListaClientePage extends StatefulWidget {
  final bool isAdmin;
  const ListaClientePage({super.key, required this.isAdmin});

  @override
  State<ListaClientePage> createState() => _ListaClientePageState();
}

class _ListaClientePageState extends State<ListaClientePage>
    with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _repository = ClienteRepository();
  Timer? _debounce;

  // **[Estado Local]** Controle de lista, paginação e visualização.
  List<Cliente> _clientes = [];
  int _page = 1;
  final int _pageSize = 10;
  bool _isLoading = true;
  bool _isFirstLoad = true;
  bool _isLoadMore = false;
  bool _hasMore = true;
  String? _error;

  String _searchTerm = '';
  ClienteSortColumn _sortColumn = ClienteSortColumn.ultimoAtendimento;
  bool _sortAscending = false;

  @override
  bool get wantKeepAlive => true;

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

  // **[Comportamento: Infinite Scroll]** Configura o listener de rolagem para disparar a paginação infinita ao se aproximar do fim da lista.
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

  // **[Ação: Carregar Clientes]** Busca os clientes no repositório tratando estados de carregamento, paginação e erros.
  // **[Origem]** A comunicação com o banco de dados paginado está no método buscarClientesPaginados do ClienteRepository. O tratamento de exceções utiliza o ErrorHandler.mapearErro.
  Future<void> _loadClientes({bool isPaginating = false}) async {
    if (!mounted) return;

    setState(() {
      if (isPaginating) {
        _isLoadMore = true;
      } else {
        _isLoading = true;
        if (_isFirstLoad) _isFirstLoad = false;
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
        setState(() {
          _error = ErrorHandler.mapearErro(e);
        });
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

  // **[Ação: Reset de Estado]** Reseta a paginação e a lista de resultados para recarregar a busca do zero.
  Future<void> _resetAndLoad() async {
    setState(() {
      _page = 1;
      _clientes = [];
      _hasMore = true;
    });
    await _loadClientes();
  }

  // **[Comportamento: Debounce de Busca]** Controla o tempo de espera (debounce de 300ms) durante a digitação antes de disparar a pesquisa, otimizando requisições.
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (_searchTerm != _searchController.text.trim()) {
        setState(() {
          _searchTerm = _searchController.text.trim();
        });
        _resetAndLoad();
      }
    });
  }

  // **[Ação: Alterar Ordenação]** Altera o campo ou a direção da ordenação dos clientes e reinicia a listagem.
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

  // **[Ação: Novo Cliente]** Abre a tela de criação de um novo cliente e atualiza a lista se um cliente for adicionado.
  // **[Origem]** A interface e lógica de cadastro completo do cliente são gerenciadas pela classe AdicionarClientePage.
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
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              heroTag: 'btnAddCliente',
              onPressed: _abrirNovoCliente,
              backgroundColor: AppColors.primaryAlternative,
              foregroundColor: AppColors.textPrimary,
              child: const Icon(AppIcons.add),
            )
          : null,
      body: Column(
        children: [
          // Componente de cabeçalho com barra de pesquisa e filtros.
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

  // **[Subcomponente: Corpo Principal]** Constrói o corpo da tela exibindo indicador de carga, erro, lista vazia ou a listagem de clientes.
  // **[Origem]** Ao clicar em um cliente na lista, a navegação direciona o usuário para DetalhesClientePage.
  Widget _buildBody() {
    // Exibe indicador central quando estiver carregando e sem dados na tela
    if (_isLoading && _clientes.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    // Exibe tela de erro amigável
    if (_error != null) {
      return AppErrorView(
        message: _error!,
        buttonText: 'Tentar Novamente',
        onTryAgain: _resetAndLoad,
        icon: Icons.cloud_off,
      );
    }

    // Exibe indicador de lista vazia caso não encontre registros
    if (_clientes.isEmpty) {
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
                      ? 'Nenhum cliente encontrado para "$_searchTerm"'
                      : 'Nenhum cliente cadastrado.',
                  icon: AppIcons.clientes,
                ),
              ),
            );
          },
        ),
      );
    }

    // Exibe a lista de clientes com suporte a Pull-to-Refresh
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
          90, // Margem inferior para evitar sobreposição pelo FAB
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _clientes.length + (_isLoadMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _clientes.length) {
            return _buildLoadingIndicator();
          }
          final cliente = _clientes[index];
          return ClienteCard(
            cliente: cliente,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DetalhesClientePage(cliente: cliente),
              ),
            ),
          );
        },
      ),
    );
  }

  // **[Estado Visual: Carregando Mais]** Exibe o indicador de progresso no rodapé da lista durante a paginação.
  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }
}
