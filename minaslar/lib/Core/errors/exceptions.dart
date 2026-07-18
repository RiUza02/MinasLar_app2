/// [Uso]: Classe base que representa qualquer erro controlado dentro da aplicação.
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

/// [Uso]: Falhas de autenticação (usuário não encontrado, senha errada, conta pendente).
class AuthException extends AppException {
  const AuthException(super.message);
}

/// [Uso]: Falhas de conexão, timeout ou falta de internet no dispositivo.
class NetworkException extends AppException {
  const NetworkException(super.message);
}

/// [Uso]: Erros de validação de dados ou regras de negócio violadas.
class ValidationException extends AppException {
  const ValidationException(super.message);
}

/// [Uso]: Erros genéricos ou não catalogados pelo sistema.
class UnknownException extends AppException {
  const UnknownException([
    super.message = 'Ocorreu um erro inesperado. Tente novamente.',
  ]);
}

/// [Uso]: Disparado quando a sessão do usuário no app não corresponde a nenhum usuário no banco.
class SessionDivergenceException extends AppException {
  const SessionDivergenceException([
    super.message = 'Sessão divergente ou expirada. Faça login novamente.',
  ]);
}
