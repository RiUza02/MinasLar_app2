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

  /// [Uso]: Ação de editar um registro.
  static const IconData editar = Icons.edit_outlined;

  /// [Uso]: Ação de excluir um registro.
  static const IconData excluir = Icons.delete_outline;

  /// [Uso]: Ação de limpar um campo de texto ou remover um filtro.
  static const IconData limpar = Icons.clear;

  /// [Uso]: Ação de atualizar/recarregar dados.
  static const IconData atualizar = Icons.sync;

  /// [Uso]: Ícone para indicar navegação para outra tela ou link.
  static const IconData navegar = Icons.chevron_right;

  /// [Uso]: Ícone para indicar um menu dropdown.
  static const IconData dropdown = Icons.arrow_drop_down;

  /// [Uso]: Ação de buscar/pesquisar.
  static const IconData buscar = Icons.search;

  /// [Uso]: Ação de ordenar uma lista.
  static const IconData ordenar = Icons.sort;

  /// [Uso]: Ação de importar dados de uma fonte externa.
  static const IconData importar = Icons.content_paste_go;

  // --- NAVEGAÇÃO PRINCIPAL (BOTTOM NAV) ---
  static const IconData dashboard = Icons.dashboard;
  static const IconData agenda = Icons.calendar_month;
  static const IconData assistente = Icons.assistant;
  static const IconData home = Icons.home;
  static const IconData clientes = Icons.people;
  static const IconData orcamentos = Icons.receipt_long_outlined;

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

  /// [Uso]: Ícone para seções de informação.
  static const IconData info = Icons.info_outline;

  /// [Uso]: Ícone para seções de histórico.
  static const IconData historico = Icons.history;

  // --- CAMPOS DE FORMULÁRIO ---

  /// [Uso]: PrefixIcon do campo de inserção de Nome Completo.
  static const IconData nome = Icons.person_outline;

  /// [Uso]: PrefixIcon do campo de número de Telefone/Celular.
  static const IconData telefone = Icons.phone_outlined;

  /// [Uso]: PrefixIcon do campo de entrada de Senha.
  static const IconData senha = Icons.lock_outline;

  /// [Uso]: PrefixIcon do campo de confirmação/repetição de Senha.
  static const IconData confirmaSenha = Icons.lock_reset;

  /// [Uso]: PrefixIcon para campos de título.
  static const IconData titulo = Icons.title;

  /// [Uso]: PrefixIcon para campos de descrição.
  static const IconData descricao = Icons.description_outlined;

  /// [Uso]: PrefixIcon para campos de valor monetário.
  static const IconData valor = Icons.monetization_on_outlined;

  /// [Uso]: PrefixIcon para campos de rua.
  static const IconData rua = Icons.add_road_outlined;

  /// [Uso]: PrefixIcon para campos de número de residência.
  static const IconData numeroCasa = Icons.home_filled;

  /// [Uso]: PrefixIcon para campos de complemento de endereço.
  static const IconData complemento = Icons.apartment_outlined;

  /// [Uso]: PrefixIcon para campos de bairro.
  static const IconData bairro = Icons.location_city_outlined;

  /// [Uso]: PrefixIcon para campos de documento (CPF/CNPJ).
  static const IconData documento = Icons.badge_outlined;

  /// [Uso]: PrefixIcon para campos de CNPJ ou nome de empresa.
  static const IconData empresa = Icons.domain;

  /// [Uso]: PrefixIcon para campos de observação.
  static const IconData observacao = Icons.note_alt_outlined;

  // --- ORÇAMENTOS E AGENDA ---

  /// [Uso]: Ícone para representar um cliente.
  static const IconData cliente = Icons.person_search_outlined;

  /// [Uso]: Ícone para orçamentos/serviços marcados como retorno/garantia.
  static const IconData retorno = Icons.sync_problem_outlined;

  /// [Uso]: Ícone para o turno da manhã.
  static const IconData manha = Icons.wb_sunny_outlined;

  /// [Uso]: Ícone para o turno da tarde.
  static const IconData tarde = Icons.wb_twilight_outlined;

  /// [Uso]: Ícone para datas genéricas, como data de entrada.
  static const IconData calendario = Icons.calendar_today_outlined;

  /// [Uso]: Ícone para datas de eventos, como data de entrega.
  static const IconData evento = Icons.event_available_outlined;

  /// [Uso]: Ícone para status pendente.
  static const IconData pendente = Icons.pending_actions;

  /// [Uso]: Ícone para adicionar um novo orçamento/serviço.
  static const IconData adicionarOrcamento = Icons.add_comment_outlined;

  /// [Uso]: Ícone para indicar um serviço urgente.
  static const IconData urgente = Icons.local_fire_department_outlined;

  // --- ENDEREÇO E CONTATO ---

  /// [Uso]: Ícone para indicar um endereço.
  static const IconData endereco = Icons.location_on_outlined;

  /// [Uso]: Ícone para ação de abrir no mapa.
  static const IconData mapa = Icons.map_outlined;

  /// [Uso]: Ícone para ação de realizar uma ligação.
  static const IconData ligar = Icons.phone_forwarded_outlined;

  // --- SUFIXOS E INTERAÇÕES ---

  /// [Uso]: Exibe a senha quando o campo está oculto (ObscureText = true).
  static const IconData verSenha = Icons.visibility;

  /// [Uso]: Oculta a senha quando o campo está visível (ObscureText = false).
  static const IconData ocultarSenha = Icons.visibility_off;

  /// [Uso]: Ícone para botão de rádio selecionado.
  static const IconData radioChecked = Icons.radio_button_checked;

  /// [Uso]: Ícone para botão de rádio não selecionado.
  static const IconData radioUnchecked = Icons.radio_button_unchecked;

  /// [Uso]: Seta para cima, usada em ordenação.
  static const IconData arrowUp = Icons.arrow_upward;

  /// [Uso]: Seta para baixo, usada em ordenação.
  static const IconData arrowDown = Icons.arrow_downward;

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
