import 'package:flutter/material.dart';
import '../../../Core/Widgets/widgets.dart';
import '../../../Features/Modelos/usuario_model.dart';

/// [uso]: Lista os integrantes da equipe com suporte a estado vazio e interações por gesto.
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
