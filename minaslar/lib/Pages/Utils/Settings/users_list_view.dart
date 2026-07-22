import 'package:flutter/material.dart';
import '../../../Core/Widgets/widgets.dart';
import '../../../Features/Modelos/usuario_model.dart';

// **[Propósito]** Componente visual responsável por renderizar a lista de usuários integrantes da equipe. Gerencia automaticamente o estado de lista vazia (exibindo um indicador padronizado) e mapeia os usuários existentes para cartões individuais (UserCard), repassando interações de toque longo.
// **[Como usar]** UsersListView(users: listaDeUsuarios, onUserLongPress: (usuario) => _exibirOpcoesDoUsuario(usuario));
class UsersListView extends StatelessWidget {
  final List<Usuario> users;
  final void Function(Usuario)? onUserLongPress;

  const UsersListView({super.key, required this.users, this.onUserLongPress});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const AppEmptyListIndicator(
        message: "Nenhum outro usuário na equipe.",
      );
    }

    return Column(
      children: users
          .map((user) => UserCard(user: user, onLongPress: onUserLongPress))
          .toList(),
    );
  }
}
