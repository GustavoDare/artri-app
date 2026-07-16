import 'dart:developer';
import 'package:artriapp/models/index.dart';
import 'package:artriapp/models/api_responses/index.dart';
import 'package:artriapp/routes/index.dart';
import 'package:artriapp/services/index.dart';
import 'package:artriapp/utils/enums/index.dart';
import 'package:artriapp/utils/helpers/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PhysicalExercisesViewModel extends ChangeNotifier {
  TrainingType? _currentTrainingType;
  ExerciseDifficulty? _currentDifficulty;
  List<ExerciseQueued> _queuedExercises = [];
  int? _currentExerciseIndex;

  List<Exercise> _customExercisesPool = [];
  final Set<int> _selectedExerciseIds = {};
  int _currentSelectionStepIndex = 0;

  ExerciseDifficulty? get currentDifficulty => _currentDifficulty;
  Set<int> get selectedExerciseIds => _selectedExerciseIds;
  int get currentSelectionStepIndex => _currentSelectionStepIndex;

  List<Map<String, dynamic>> get customSteps {
    if (_currentDifficulty == ExerciseDifficulty.easy) {
      return [
        {'category': 'mobilidade', 'title': 'mobilidade', 'requiredCount': 2},
        {'category': 'aquecimento', 'title': 'aquecimento', 'requiredCount': 2},
        {'category': 'pernas', 'title': 'pernas', 'requiredCount': 2},
        {'category': 'braços', 'title': 'braços', 'requiredCount': 2},
        {'category': 'tronco', 'title': 'tronco', 'requiredCount': 1},
        {'category': 'alongamento', 'title': 'alongamento', 'requiredCount': 3},
      ];
    } else if (_currentDifficulty == ExerciseDifficulty.medium) {
      return [
        {'category': 'mobilidade', 'title': 'mobilidade', 'requiredCount': 2},
        {'category': 'aquecimento', 'title': 'aquecimento', 'requiredCount': 3},
        {'category': 'pernas', 'title': 'pernas', 'requiredCount': 3},
        {'category': 'braços', 'title': 'braços', 'requiredCount': 3},
        {'category': 'tronco', 'title': 'tronco', 'requiredCount': 2},
        {'category': 'alongamento', 'title': 'alongamento', 'requiredCount': 3},
      ];
    } else {
      return [
        {'category': 'mobilidade', 'title': 'mobilidade', 'requiredCount': 1},
        {'category': 'aquecimento', 'title': 'aquecimento', 'requiredCount': 3},
        {'category': 'pernas', 'title': 'pernas', 'requiredCount': 3},
        {'category': 'braços', 'title': 'braços', 'requiredCount': 3},
        {'category': 'tronco', 'title': 'tronco', 'requiredCount': 2},
        {'category': 'alongamento', 'title': 'alongamento', 'requiredCount': 3},
      ];
    }
  }

  List<ExerciseQueued> get exercises => _queuedExercises;
  ExerciseQueued? get currentExercise => _currentExerciseIndex == null ? null : _queuedExercises[_currentExerciseIndex ?? 0];

  final PhysicalExercisesService _physicalExercisesService;
  PhysicalExercisesViewModel(this._physicalExercisesService);

  void handleTrainingTypeSelection(TrainingType type, BuildContext context) {
    _currentTrainingType = type;
    context.go(_getRouteForTrainingType(type));
  }

  String _getRouteForTrainingType(TrainingType type) {
    switch (type) {
      case TrainingType.hands:
        return PhysicalExerciseRoutes.handExercises;
      case TrainingType.feet:
        return PhysicalExerciseRoutes.feetExercises;
      case TrainingType.custom:
        return PhysicalExerciseRoutes.customExercises;
      default:
        return PhysicalExerciseRoutes.customExercises;
    }
  }

  void handleDifficultySelection(
      ExerciseDifficulty difficulty,
      BuildContext context,
      ) async {
    _currentDifficulty = difficulty;

    if (_currentTrainingType == null) {
      log('Error: Training type not selected');
      return;
    }

    var currentPath = RouterHelper.getUriFromContext(context).path;

    try {
      var exercises = await _physicalExercisesService.getExercisesFromTraining(
        _currentTrainingType!,
        _currentDifficulty!,
      );

      if (_currentTrainingType == TrainingType.custom) {
        setupCustomFlow(exercises);
        context.go('$currentPath/${difficulty.toString()}');
        return;
      }

      _queuedExercises = _queueExercises(exercises);
      context.go('$currentPath/${difficulty.toString()}');

    } catch (e, stackTrace) {
      log('🔴 Erro detalhado: $e');
      log('🔴 StackTrace: $stackTrace');
    }
  }

  List<ExerciseQueued> _queueExercises(List<Exercise> exercises) {
    var queue = exercises
        .map(
          (e) => ExerciseQueued(
        exercise: e,
        isFirst: exercises.indexOf(e) == 0,
        isLast: exercises.indexOf(e) == exercises.length - 1,
      ),
    )
        .toList();

    _currentExerciseIndex = 0;
    return queue;
  }

  void handleNextExercise(BuildContext context) {
    if (_currentExerciseIndex == null) return;

    if (currentExercise!.isLast) {
      context.go(PhysicalExerciseRoutes.congratulations);
      return;
    }

    _currentExerciseIndex = _currentExerciseIndex! + 1;
    context.go(getExerciseRoute(context));
  }

  void handlePreviousExercise(BuildContext context) {
    if (_currentExerciseIndex == null) return;
    if (currentExercise!.isFirst) return;

    _currentExerciseIndex = _currentExerciseIndex! - 1;
    context.go(getExerciseRoute(context));
  }

  void handleStartExercises(BuildContext context) {
    _currentExerciseIndex = 0;
    context.go(getExerciseRoute(context));
  }

  void handleCompleteExercise(BuildContext context) {
    if (_currentExerciseIndex == null) return;
    currentExercise!.markAsCompleted();
    handleNextExercise(context);
  }

  String getExerciseRoute(BuildContext context) {
    var currentPath = RouterHelper.getUriFromContext(context);
    var currentPathSegments = currentPath.pathSegments;
    var hasCurrentExerciseId = int.tryParse(currentPathSegments.last) != null;
    var cleanedPath = currentPath.path;

    if (hasCurrentExerciseId) {
      cleanedPath = '/${currentPathSegments.sublist(0, currentPathSegments.length - 1).join('/')}';
    }
    return '$cleanedPath/${currentExercise!.id}';
  }

  // ==========================================
  // MÉTODOS DO FLUXO PERSONALIZADO (WIZARD)
  // ==========================================

  void setupCustomFlow(List<Exercise> allExercises) {
    _customExercisesPool = List.from(allExercises);
    _selectedExerciseIds.clear();
    _queuedExercises = [];
    _currentSelectionStepIndex = 0;
    _currentExerciseIndex = null;

    _injectDefaultExercises();

    notifyListeners();
  }

  void _injectDefaultExercises() {
    int idCounter = -1000;
    final diff = _currentDifficulty ?? ExerciseDifficulty.easy;

    void addDefault(String name) {
      if (!_customExercisesPool.any((e) => e.name.toLowerCase().trim() == name.toLowerCase().trim())) {
        _customExercisesPool.add(Exercise(
          id: idCounter--,
          name: name,
          description: 'Mantenha a postura correta e realize o movimento lentamente. Foque na contração do músculo. Faça o exercício mantendo a posição conforme o nível e depois descanse.',
          tutorialLink: '',
          difficulty: diff,
          details: ExerciseDetails(rest: 30, reps: 10, sets: 2, duration: 40),
        ));
      }
    }

    // Mobilidade
    addDefault('Círculos com a perna');
    addDefault('Círculos com o tornozelo');
    addDefault('Pernas para frente e para trás');
    addDefault('Círculos com os braços');
    addDefault('Subir e descer os ombros');
    addDefault('Círculos com os punhos');
    addDefault('Descer e subir o tronco sentado');
    addDefault('Gato arrepiado');

    // Aquecimento
    addDefault('Marcha no lugar');
    addDefault('Marcha no lugar com o toque no joelho');
    addDefault('Polichinelo adaptado');

    // Pernas
    addDefault('Sentar e levantar da cadeira');
    addDefault('Subir o quadril deitado');
    addDefault('Subir e descer quadril deitado');
    addDefault('Ficar na ponta dos pés sentado');
    addDefault('Abrir a perna em pé');

    // Braços
    addDefault('Elevação lateral dos braços');
    addDefault('Dobrar o cotovelo');
    addDefault('Elevação frontal dos braços');
    addDefault('Rotação do braço para fora');
    addDefault('Rotação do braço para dentro');

    // Tronco
    addDefault('Abdominal em pé');
    addDefault('Abdominal deitado');
    addDefault('Prancha com apoio dos joelhos');
    addDefault('Prancha');

    // Alongamento
    addDefault('Parte anterior da coxa');
    addDefault('Parte posterior da coxa');
    addDefault('Panturrilha');
    addDefault('Braços esticados para cima');
    addDefault('Braços esticados para trás');
    addDefault('Braços esticados na frente');
    addDefault('Glúteos');
  }

  String getExerciseCategory(Exercise exercise) {
    final nameLower = exercise.name.toLowerCase();

    final mobilidade = [
      'círculos com a perna', 'círculos com o tornozelo', 'pernas para frente e para trás',
      'círculos com os braços', 'subir e descer os ombros', 'círculos com os punhos',
      'descer e subir o tronco sentado', 'gato arrepiado'
    ];
    final aquecimento = [
      'marcha no lugar', 'marcha no lugar com o toque no joelho', 'polichinelo adaptado'
    ];
    final pernas = [
      'sentar e levantar da cadeira', 'subir o quadril deitado', 'subir e descer quadril deitado',
      'ficar na ponta dos pés sentado', 'abrir a perna em pé'
    ];
    final bracos = [
      'elevação lateral dos braços', 'dobrar o cotovelo', 'elevação frontal dos braços',
      'rotação do braço para fora', 'rotação do braço para dentro'
    ];
    final tronco = [
      'abdominal em pé', 'abdominal deitado', 'prancha com apoio dos joelhos', 'prancha'
    ];
    final alongamento = [
      'parte anterior da coxa', 'parte posterior da coxa', 'panturrilha',
      'braços esticados para cima', 'braços esticados para trás', 'braços esticados na frente', 'glúteos'
    ];

    if (mobilidade.any((ex) => nameLower.contains(ex))) return 'mobilidade';
    if (aquecimento.any((ex) => nameLower.contains(ex))) return 'aquecimento';
    if (alongamento.any((ex) => nameLower.contains(ex))) return 'alongamento';
    if (pernas.any((ex) => nameLower.contains(ex))) return 'pernas';
    if (bracos.any((ex) => nameLower.contains(ex))) return 'braços';
    if (tronco.any((ex) => nameLower.contains(ex))) return 'tronco';

    if (nameLower.contains('mobilidade')) return 'mobilidade';
    if (nameLower.contains('aquecimento')) return 'aquecimento';
    if (nameLower.contains('alongamento')) return 'alongamento';
    if (nameLower.contains('perna') || nameLower.contains('inferior')) return 'pernas';
    if (nameLower.contains('braço') || nameLower.contains('superior') || nameLower.contains('ombro') || nameLower.contains('cotovelo') || nameLower.contains('punho')) return 'braços';
    if (nameLower.contains('tronco') || nameLower.contains('costas') || nameLower.contains('prancha') || nameLower.contains('abdominal')) return 'tronco';

    return 'outros';
  }

  List<Exercise> getFilteredExercisesForCurrentStep() {
    final currentCategory = customSteps[_currentSelectionStepIndex]['category'] as String;
    final categoryExercises = _customExercisesPool.where((ex) => getExerciseCategory(ex) == currentCategory).toList();

    final uniqueExercises = <String, Exercise>{};
    for (var ex in categoryExercises) {
      final baseName = ex.name.split('-').first.trim().toLowerCase();
      if (!uniqueExercises.containsKey(baseName)) {
        uniqueExercises[baseName] = ex;
      }
    }

    return uniqueExercises.values.toList();
  }

  bool isCurrentStepValid() {
    final requiredCount = customSteps[_currentSelectionStepIndex]['requiredCount'] as int;
    final currentCategoryExercises = getFilteredExercisesForCurrentStep();
    final selectedCountInStep = currentCategoryExercises.where((ex) => _selectedExerciseIds.contains(ex.id)).length;

    return selectedCountInStep == requiredCount;
  }

  void handleNextSelectionStep(BuildContext context) {
    if (_currentSelectionStepIndex < customSteps.length - 1) {
      _currentSelectionStepIndex++;
      notifyListeners();
    } else {
      var selected = _customExercisesPool.where((ex) => _selectedExerciseIds.contains(ex.id)).toList();

      // ORDENAÇÃO: Garante que a fila final respeite a ordem do customSteps
      selected.sort((a, b) {
        final catA = getExerciseCategory(a);
        final catB = getExerciseCategory(b);

        final indexA = customSteps.indexWhere((step) => step['category'] == catA);
        final indexB = customSteps.indexWhere((step) => step['category'] == catB);

        return indexA.compareTo(indexB);
      });

      _queuedExercises = _queueExercises(selected);

      var currentPath = RouterHelper.getUriFromContext(context).path;
      context.go('$currentPath/overview'.replaceAll('/selection/overview', '/overview'));
    }
  }

  void handlePreviousSelectionStep() {
    if (_currentSelectionStepIndex > 0) {
      _currentSelectionStepIndex--;
      notifyListeners();
    }
  }

  void toggleExerciseSelection(int exerciseId) {
    if (_selectedExerciseIds.contains(exerciseId)) {
      _selectedExerciseIds.remove(exerciseId);
    } else {
      _selectedExerciseIds.add(exerciseId);
    }
    notifyListeners();
  }
}