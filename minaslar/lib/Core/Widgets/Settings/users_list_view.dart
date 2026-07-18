import 'package:flutter/material.dart';
import '../widgets.dart';
import '../../../Features/Modelos/usuario_model.dart';

/// Lista reativa para exibição dos membros de uma equipe.
///
/// [Uso] Este componente renderiza a listagem visual dos integrantes da equipe.
/// Ele trata automaticamente o estado vazio exibindo um indicador padrão do sistema
/// e mapeia cada usuário para seu respectivo cartão (`UserCard`), suportando também
/// interações de clique longo.
class UsersListView extends StatelessWidget {
  /// Lista de usuários que serão exibidos na tela.
  final List<Usuario> users;

  /// Ação opcional disparada ao pressionar e segurar o cartão de um usuário.
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
