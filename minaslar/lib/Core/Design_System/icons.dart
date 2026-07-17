import 'package:flutter/material.dart';

class AppIcons {
  AppIcons._();

  // --- CABEÇALHOS E SEÇÕES ---

  /// [Uso]: Ícone principal decorativo no topo da tela de criação de conta.
  static const IconData criarContaHeader = Icons.person_add_outlined;

  /// [Uso]: Identificador visual para o bloco/card de dados pessoais.
  static const IconData dadosPessoaisSection = Icons.person;

  /// [Uso]: Identificador visual para o bloco/card de segurança e senhas.
  static const IconData segurancaSection = Icons.lock;

  // --- CAMPOS DE TEXTO (PREFIXOS) ---

  /// [Uso]: PrefixIcon do campo de inserção de Nome Completo.
  static const IconData nome = Icons.person_outline;

  /// [Uso]: PrefixIcon do campo de número de Telefone/Celular.
  static const IconData telefone = Icons.phone_android;

  /// [Uso]: PrefixIcon do campo de entrada de Senha.
  static const IconData senha = Icons.lock_outline;

  /// [Uso]: PrefixIcon do campo de confirmação/repetição de Senha.
  static const IconData confirmaSenha = Icons.lock_reset;

  // --- SUFIXOS E INTERAÇÕES ---

  /// [Uso]: Exibe a senha quando o campo está oculto (ObscureText = true).
  static const IconData verSenha = Icons.visibility;

  /// [Uso]: Oculta a senha quando o campo está visível (ObscureText = false).
  static const IconData ocultarSenha = Icons.visibility_off;

  // --- VALIDAÇÕES E STATUS ---

  /// [Uso]: Indicador de sucesso ou requisito preenchido corretamente.
  static const IconData valido = Icons.check_circle;

  /// [Uso]: Indicador de erro ou requisito pendente/incorreto.
  static const IconData invalido = Icons.cancel;
}
