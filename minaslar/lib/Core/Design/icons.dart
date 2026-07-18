import 'package:flutter/material.dart';

class AppIcons {
  AppIcons._();

  // --- NAVEGAÇÃO E AÇÕES GERAIS ---

  /// [Uso]: Ícone padrão para botões de "voltar" em AppBars ou cabeçalhos.
  static const IconData voltar = Icons.arrow_back;

  /// [Uso]: Ponto de entrada para a tela de configurações do aplicativo.
  static const IconData settings = Icons.settings;

  /// [Uso]: Ação de deslogar / encerrar a sessão do usuário.
  static const IconData logout = Icons.logout;

  /// [Uso]: Atalho para iniciar uma conversa via WhatsApp ou chat interno.
  static const IconData chat = Icons.chat;

  /// [Uso]: Ícone genérico para ações de "adicionar". Usado em testes.
  static const IconData add = Icons.add;

  // --- NAVEGAÇÃO PRINCIPAL (BOTTOM NAV) ---
  static const IconData dashboard = Icons.dashboard;
  static const IconData agenda = Icons.calendar_month;
  static const IconData assistente = Icons.assistant;
  static const IconData home = Icons.home;
  static const IconData clientes = Icons.people;
  static const IconData orcamentos = Icons.monetization_on;

  // --- CABEÇALHOS E SEÇÕES ---

  /// [Uso]: Ícone principal decorativo no topo da tela de criação de conta.
  static const IconData criarContaHeader = Icons.person_add_outlined;

  /// [Uso]: Identificador visual para o bloco/card de dados pessoais.
  static const IconData dadosPessoaisSection = Icons.person;

  /// [Uso]: Identificador visual para o bloco/card de segurança e senhas.
  static const IconData segurancaSection = Icons.lock;

  /// [Uso]: Identificador visual para a seção de listagem de equipe.
  static const IconData equipeSection = Icons.group_outlined;

  /// [Uso]: Ícone para o botão de aprovações de acesso pendentes.
  static const IconData aprovacoesPendentes =
      Icons.person_add_disabled_outlined;

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

  /// [Uso]: Ícone para telas de erro genéricas ou falhas de carregamento.
  static const IconData erro = Icons.error_outline;

  /// [Uso]: Ícone para indicar seções ou telas em desenvolvimento.
  static const IconData emConstrucao = Icons.construction_outlined;
}
