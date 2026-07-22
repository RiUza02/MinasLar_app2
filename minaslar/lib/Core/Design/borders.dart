import 'package:flutter/material.dart';

import 'colors.dart';

// [Propósito]: Centraliza a estilização de bordas da aplicação para manter a consistência na UI.
// [Como usar]: AppBorders.standard (aplique na propriedade 'border' de Containers, BoxDecorations, etc.).
class AppBorders {
  AppBorders._();

  // [Propósito]: Borda neutra e fina, usada como estilo padrão na maioria dos cards e contêineres.
  static final Border standard = Border.all(
    color: AppColors.borderLight,
    width: 1.0,
  );

  // [Propósito]: Borda espessa de alerta para destacar erros, falhas ou elementos visuais de urgência.
  static final Border urgent = Border.all(color: AppColors.error, width: 2.0);

  // [Propósito]: Identificador visual para cartões de orçamento alocados no turno da manhã.
  static final Border morningShift = Border.all(
    color: AppColors.morningShift,
    width: 2.0,
  );

  // [Propósito]: Identificador visual para cartões de orçamento alocados no turno da tarde.
  static final Border afternoonShift = Border.all(
    color: AppColors.afternoonShift,
    width: 2.0,
  );
}
