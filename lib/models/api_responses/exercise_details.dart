class ExerciseDetails {
  final int? rest;
  final int? reps;
  final int sets;
  final int? duration;

  ExerciseDetails({
    required this.rest,
    required this.reps,
    required this.sets,
    required this.duration,
  });

  factory ExerciseDetails.fromString(String value) {
    RegExp descriptionRegex = RegExp(
      r'sets_reps:\s?(?<sets>\d+)x\s?((?<reps>\d+)|((?<duration>\d+)\w))'
      r';\srest:\s?(((?<rest>\d+)\w)|(–|-))',
      caseSensitive: false,
      multiLine: true,
    );
    final match = descriptionRegex.firstMatch(value);

    return ExerciseDetails(
      rest: match?.namedGroup('rest') != null
          ? int.parse(match!.namedGroup('rest')!)
          : null,
      reps: match?.namedGroup('reps') != null
          ? int.parse(match!.namedGroup('reps')!)
          : null,
      sets: match?.namedGroup('sets') != null
          ? int.parse(match!.namedGroup('sets')!)
          : 2,
      duration: match?.namedGroup('duration') != null
          ? int.parse(match!.namedGroup('duration')!)
          : null,
    );
  }
}
