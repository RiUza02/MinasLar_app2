import '../../../Core/Design/design_system.dart';
import '../../../Core/Widgets/widgets.dart';
import '../../../Features/Modelos/usuario_model.dart';
import 'profile_info_card.dart';
import 'users_list_view.dart';

/// [uso]: Corpo principal da tela de configurações, gerenciando os estados de carregamento, erro e conteúdo.
class SettingsBody extends StatelessWidget {
  final bool isLoading;
  final Usuario? currentUser;
  final List<Usuario> authenticatedUsers;
  final String errorMessage;
  final bool isAdmin;
  final Color themeColor;

  final Future<void> Function() onRefresh;
  final VoidCallback onTryAgain;
  final VoidCallback onEditProfile;
  final void Function(Usuario) onUserLongPress;

  const SettingsBody({
    super.key,
    required this.isLoading,
    required this.currentUser,
    required this.authenticatedUsers,
    required this.errorMessage,
    required this.isAdmin,
    required this.themeColor,
    required this.onRefresh,
    required this.onTryAgain,
    required this.onEditProfile,
    required this.onUserLongPress,
  });

  @override
  Widget build(BuildContext context) {
    // Carregamento inicial antes de obter os dados
    if (isLoading && currentUser == null) {
      return Center(child: CircularProgressIndicator(color: themeColor));
    }

    // Tela de erro caso os dados do usuário não estejam disponíveis
    if (currentUser == null) {
      return AppErrorView(
        message: errorMessage.isNotEmpty
            ? errorMessage
            : "Não foi possível carregar os dados. Verifique sua conexão e tente novamente.",
        buttonText: "Tentar Novamente",
        onTryAgain: onTryAgain,
      );
    }

    // Conteúdo principal renderizado com suporte a Pull-to-Refresh
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: themeColor,
      backgroundColor: AppColors.cardBackground,
      child: ListView(
        padding: const EdgeInsets.all(AppDimensions.spaceLarge),
        children: [
          ProfileInfoCard(
            currentUser: currentUser!,
            onEdit: onEditProfile,
            themeColor: themeColor,
          ),
          const SizedBox(height: AppDimensions.spaceXLarge),
          AppSectionHeader(
            icon: AppIcons.equipeSection,
            title: 'EQUIPE AUTENTICADA',
            count: authenticatedUsers.length,
            countLabel: authenticatedUsers.length == 1 ? 'usuário' : 'usuários',
          ),
          UsersListView(
            users: authenticatedUsers,
            onUserLongPress: isAdmin ? onUserLongPress : null,
          ),
        ],
      ),
    );
  }
}
