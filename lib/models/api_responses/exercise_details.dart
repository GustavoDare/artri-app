import 'package:artriapp/utils/extensions/string_extensions.dart';

class ExerciseDetails {
  final int? rest;
  final int? reps;
  final int sets;
  final int? duration;
  final String? equipment;
  final String? info;

  ExerciseDetails({
    required this.rest,
    required this.reps,
    required this.sets,
    required this.duration,
    required this.equipment,
    required this.info,
  });

  factory ExerciseDetails.fromString(String value) {
    RegExp descriptionRegex = RegExp(
      r'Série(s?):\s?(?<sets>\d+)x\s?((?<duration>\d+)s|(?<reps>\d+))'
      r'(\s?\-\s?(?<info>[a-zA-ZÀ-ÿ\s]+\d+s))?'
      r'([\s\r\n]*(?<rest>\d+)s\sde\sdescanso)?'
      r'([\s\r\n]*Equipamento:\s?(?<equipment>[a-zA-ZÀ-ÿ\s]+))?',
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
      equipment: match?.namedGroup('equipment')?.capitalize(),
      info: match?.namedGroup('info'),
    );
  }
}
