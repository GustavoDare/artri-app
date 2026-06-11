import 'package:artriapp/models/api_responses/index.dart';
import 'package:artriapp/utils/enums/exercise_difficulty.dart';

class Exercise {
  final int id;
  final String name;
  final String description;
  final String tutorialLink;
  final ExerciseDifficulty difficulty;
  final ExerciseDetails details;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.tutorialLink,
    required this.difficulty,
    required this.details,
  });

  factory Exercise.fromJson(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      tutorialLink: map['tutorial_link'],
      difficulty: ExerciseDifficulty.fromString(map['difficulty']),
      details: ExerciseDetails.fromString(
        "sets_reps: ${map['sets_reps']}; rest: ${map['rest_time']}",
      ),
    );
  }
}
