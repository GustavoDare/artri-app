enum TrainingType {
  custom,
  hands,
  aerobic,
  mobility,
  feet,
  superiorBoost,
  inferiorBoost,
  coreBoost,
  stretching;

  @override
  toString() {
    switch (this) {
      case TrainingType.custom:
        return 'PERSONALIZADO';
      case TrainingType.hands:
        return 'MÃOS';
      case TrainingType.feet:
        return 'PÉS';
      case TrainingType.aerobic:
        return 'AERÓBICO';
      case TrainingType.mobility:
        return 'MOBILIDADE';
      case TrainingType.superiorBoost:
        return 'FORTALECIMENTO MEMBRO SUPERIOR';
      case TrainingType.inferiorBoost:
        return 'FORTALECIMENTO MEMBRO INFERIOR';
      case TrainingType.coreBoost:
        return 'FORTALECIMENTO CORE';
      case TrainingType.stretching:
        return 'ALONGAMENTO';
    }
  }
}
