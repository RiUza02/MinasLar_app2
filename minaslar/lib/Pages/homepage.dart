import 'package:flutter/material.dart';
import '../core/design_system/design_system.dart';

// ============================================================================
// REGISTRO DE MIGRAÇÃO DE TELAS (DIRETÓRIO: 'Rascunho' -> Design System)
// ============================================================================
// Status atual: 0/6 telas migradas. Todas estão operando via _placeholder.
//
// [ ] Dashboard  (Exclusivo Administrador)
// [ ] Agenda     (Administrador / Usuário Comum)
// [ ] Assistente (Administrador / Usuário Comum)
// [ ] Home       (Administrador / Usuário Comum)
// [ ] Clientes   (Administrador / Usuário Comum)
// [ ] Orçamentos (Administrador / Usuário Comum)
// ============================================================================

/// Tela principal de navegação (Shell) pós-login.
///
/// Controla a exibição das seções por meio de um [PageView] e uma
/// [BottomNavigationBar], adaptando as opções exibidas conforme o perfil
/// definido por [isAdmin].
class Overview extends StatefulWidget {
  final bool isAdmin;
  final String nomeUsuario;

  const Overview({super.key, required this.isAdmin, required this.nomeUsuario});

  @override
  State<Overview> createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {
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
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: 'Agenda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assistant),
          label: 'Assistente',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Clientes'),
        BottomNavigationBarItem(
          icon: Icon(Icons.monetization_on),
          label: 'Orçamentos',
        ),
      ];
    } else {
      _selectedIndex = 2; // Inicia na tela "Home"
      _navBarItems = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: 'Agenda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assistant),
          label: 'Assistente',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Clientes'),
        BottomNavigationBarItem(
          icon: Icon(Icons.monetization_on),
          label: 'Orçamentos',
        ),
      ];
    }

    // Gera páginas temporárias enquanto as telas reais não são migradas
    _pages = _navBarItems.map((item) => _placeholder(item.label!)).toList();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Executa a transição animada entre as telas do PageView.
  void _navegarParaPagina(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  /// Sincroniza o índice da barra de navegação com o gesto de mudança de página.
  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Gera uma interface visual temporária para telas ainda não implementadas.
  Widget _placeholder(String label) {
    return Scaffold(
      appBar: AppBar(
        title: Text(label),
        backgroundColor: widget.isAdmin ? AppColors.error : AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spaceLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.construction_outlined,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define a cor de fundo da barra de navegação pelo perfil do usuário
    final Color navBarColor = widget.isAdmin
        ? AppColors.error
        : AppColors.primary;

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        // Trava o arrasto manual para forçar a navegação exclusivamente pelos ícones
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
