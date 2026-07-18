import 'package:flutter/material.dart';

import 'colors.dart';

/// Centraliza as estilizações de borda para consistência na UI.
class AppBorders {
  AppBorders._();

  /// Borda padrão para cards e elementos.
  static final Border standard = Border.all(
    color: AppColors.borderLight,
    width: 1.0,
  );

  /// Borda com destaque para elementos urgentes ou com erro.
  static final Border urgent = Border.all(color: AppColors.error, width: 2.0);

  /// Borda para orçamentos agendados para o turno da manhã.
  static final Border morningShift = Border.all(
    color: AppColors.morningShift,
    width: 2.0,
  );

  /// Borda para orçamentos agendados para o turno da tarde.
  static final Border afternoonShift = Border.all(
    color: AppColors.afternoonShift,
    width: 2.0,
  );
}
