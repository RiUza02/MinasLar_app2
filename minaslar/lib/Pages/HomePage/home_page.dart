import '../../../core/Design/design_system.dart';
import '../Settings/settings_page.dart';
import 'lista_cliente.dart';
import 'overview.dart'; // Mantido conforme seu original (verifique se não há auto-referência cíclica no seu projeto)

// ============================================================================
// REGISTRO DE MIGRAÇÃO DE TELAS (DIRETÓRIO: 'Rascunho' -> Design System)
// ============================================================================
// Status atual: 3/7 telas migradas. As demais estão operando via _placeholder.
//
// [ ] Dashboard  (Exclusivo Administrador)
// [ ] Agenda     (Administrador / Usuário Comum)
// [ ] Assistente (Administrador / Usuário Comum)
// [X] Home       (Adicionado)
// [X] Clientes   (Adicionado)
// [ ] Orçamentos (Administrador / Usuário Comum)
// [X] Configurações (Adicionado)
// ============================================================================

/// [uso] Tela principal de navegação (Shell) pós-login.
///
/// Controla a exibição das seções por meio de um [PageView] e uma
/// [BottomNavigationBar], adaptando as opções exibidas conforme o perfil
/// definido por [isAdmin].
class HomePage extends StatefulWidget {
  final bool isAdmin;
  final String nomeUsuario;

  const HomePage({super.key, required this.isAdmin, required this.nomeUsuario});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PageController _pageController;
  late int _selectedIndex;

  late final List<Widget> _pages;
  late final List<BottomNavigationBarItem> _navBarItems;

  @override
  void initState() {
    super.initState();

    // Configuração de rotas e índices conforme as permissões de acesso
    if (widget.isAdmin) {
      _selectedIndex = 3; // Inicia na tela "Home"
      _navBarItems = const [
        BottomNavigationBarItem(
          icon: Icon(AppIcons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(icon: Icon(AppIcons.agenda), label: 'Agenda'),
        BottomNavigationBarItem(
          icon: Icon(AppIcons.assistente),
          label: 'Assistente',
        ),
        BottomNavigationBarItem(icon: Icon(AppIcons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(AppIcons.clientes),
          label: 'Clientes',
        ),
        BottomNavigationBarItem(
          icon: Icon(AppIcons.orcamentos),
          label: 'Orçamentos',
        ),
      ];
    } else {
      _selectedIndex = 2; // Inicia na tela "Home"
      _navBarItems = const [
        BottomNavigationBarItem(icon: Icon(AppIcons.agenda), label: 'Agenda'),
        BottomNavigationBarItem(
          icon: Icon(AppIcons.assistente),
          label: 'Assistente',
        ),
        BottomNavigationBarItem(icon: Icon(AppIcons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(AppIcons.clientes),
          label: 'Clientes',
        ),
        BottomNavigationBarItem(
          icon: Icon(AppIcons.orcamentos),
          label: 'Orçamentos',
        ),
      ];
    }

    // Mapeia os itens da barra de navegação para as páginas correspondentes.
    _pages = _navBarItems.map((item) {
      switch (item.label) {
        case 'Home':
          return OverView(isAdmin: widget.isAdmin);
        case 'Clientes':
          // Redireciona a aba Clientes para a página com o status de admin
          return ListaClientePage(isAdmin: widget.isAdmin);
        default:
          return _placeholder(item.label!);
      }
    }).toList();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// [uso] Executa a transição animada entre as telas do PageView.
  void _navegarParaPagina(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  /// [uso] Sincroniza o índice da barra de navegação com o gesto de mudança de página.
  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// [uso] Gera uma interface visual temporária para telas ainda não implementadas.
  Widget _placeholder(String label) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              AppIcons.emConstrucao,
              size: 64,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: AppDimensions.spaceLarge),
            Text(
              'Tela em Construção',
              style: AppTextStyles.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spaceSmall),
            Text(
              'A funcionalidade de "$label" estará disponível em breve.',
              style: AppTextStyles.bodyMediumSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define a cor de fundo da barra de navegação pelo perfil do usuário
    final Color navBarColor = widget.isAdmin
        ? AppColors.primaryAlternative
        : AppColors.primary;
    final String currentPageTitle = _navBarItems[_selectedIndex].label!; //

    return Scaffold(
      // MODIFICAÇÃO: O AppBar inteiro agora é condicional e tem tamanho personalizado
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40.0),
        child: AppBar(
          title: Text(currentPageTitle),
          backgroundColor: navBarColor,
          foregroundColor: AppColors.textPrimary,
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(AppIcons.settings),
              tooltip: 'Configurações',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(isAdmin: widget.isAdmin),
                  ),
                );
              },
            ),
          ],
        ),
      ), // 👈 Faz a barra sumir por completo em qualquer aba que não seja a Home![cite: 7]
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navegarParaPagina,
        backgroundColor: navBarColor,
        selectedItemColor: AppColors.textPrimary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        items: _navBarItems,
      ),
    );
  }
}
