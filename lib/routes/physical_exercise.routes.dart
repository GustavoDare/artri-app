import 'package:artriapp/models/index.dart';
import 'package:artriapp/routes/index.dart';
import 'package:artriapp/utils/helpers/index.dart';
import 'package:artriapp/utils/index.dart';
import 'package:artriapp/views/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../views/physical_exercise/widgets/custom_exercise_intro_view.dart';
import '../views/physical_exercise/widgets/custom_exercise_selector_view.dart';

class PhysicalExerciseRoutes implements RoutesSession {
  static final String _base = ExerciseOptionsRoutes.physicalExercise;
  static String handExercises = '$_base/hand';
  static String feetExercises = '$_base/feet';
  static String customExercises = '$_base/custom';
  static String congratulations = '$_base/congratulations';

  static List<RouteBase> getGoRoutes() => [
    GoRoute(
      parentNavigatorKey: RouterKeys.appRoutesKey,
      path: 'congratulations',
      builder: (context, state) => CongratulationsView(),
    ),
    ShellRoute(
      parentNavigatorKey: RouterKeys.appRoutesKey,
      builder: (context, state, child) => PhysicalExerciseView(
        title: 'Mãos',
        child: child,
        subtitle: DifficultyHelper.getDifficultyText(
          state.pathParameters['difficulty'],
        ),
      ),
      routes: [
        GoRoute(
          path: 'hand',
          builder: (context, state) => const LevelExerciseSelector(),
          routes: [
            GoRoute(
              path: ':difficulty',
              builder: (context, state) =>
              const PhysicalExerciseRoutineOverview(),
              routes: [
                GoRoute(
                  path: ':exerciseId',
                  builder: (context, state) => ExerciseRoutineStepView(
                    key: ValueKey(state.pathParameters['exerciseId']),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    ShellRoute(
      parentNavigatorKey: RouterKeys.appRoutesKey,
      builder: (context, state, child) => PhysicalExerciseView(
        title: 'Pés',
        child: child,
        subtitle: DifficultyHelper.getDifficultyText(
          state.pathParameters['difficulty'],
        ),
      ),
      routes: [
        GoRoute(
          path: 'feet',
          builder: (context, state) => const LevelExerciseSelector(),
          routes: [
            GoRoute(
              path: ':difficulty',
              builder: (context, state) =>
              const PhysicalExerciseRoutineOverview(),
              routes: [
                GoRoute(
                  path: ':exerciseId',
                  builder: (context, state) => ExerciseRoutineStepView(
                    key: ValueKey(state.pathParameters['exerciseId']),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    // ROTA PARA OS EXERCÍCIOS PERSONALIZADOS AJUSTADA
    ShellRoute(
      parentNavigatorKey: RouterKeys.appRoutesKey,
      builder: (context, state, child) => PhysicalExerciseView(
        title: 'Personalizado',
        child: child,
        subtitle: DifficultyHelper.getDifficultyText(
          state.pathParameters['difficulty'],
        ),
      ),
      routes: [
        GoRoute(
          path: 'custom',
          builder: (context, state) => const LevelExerciseSelector(),
          routes: [
            GoRoute(
              // A tela inicial do Custom agora é a Intro
              path: ':difficulty',
              builder: (context, state) => const CustomExerciseIntroView(),
              routes: [
                GoRoute(
                  path: 'selection',
                  builder: (context, state) => const CustomExerciseSelectorView(),
                ),
                GoRoute(
                  path: 'overview',
                  builder: (context, state) => const PhysicalExerciseRoutineOverview(),
                  routes: [
                    GoRoute(
                      path: ':exerciseId',
                      builder: (context, state) => ExerciseRoutineStepView(
                        key: ValueKey(state.pathParameters['exerciseId']),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ];
}