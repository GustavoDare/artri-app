import 'package:artriapp/utils/index.dart';
import 'package:artriapp/view_models/index.dart';
import 'package:artriapp/views/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CustomExerciseSelectorView extends StatelessWidget {
  const CustomExerciseSelectorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PhysicalExercisesViewModel>(
      builder: (context, viewModel, child) {
        final currentStep = viewModel.customSteps[viewModel.currentSelectionStepIndex];
        final exercisesInStep = viewModel.getFilteredExercisesForCurrentStep();
        final isValid = viewModel.isCurrentStepValid();

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (viewModel.currentSelectionStepIndex > 0) {
              viewModel.handlePreviousSelectionStep();
            } else {
              context.pop();
            }
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                spacing: 24,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    // CORREÇÃO: O texto agora reflete que deve ser o número exato, sem o "ou mais"
                    'Selecione ${currentStep['requiredCount']} exercício(s) de ${currentStep['title']}:',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(fontSize: 20, color: AppColors.darkGreen),
                  ),
                  if (exercisesInStep.isEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("Em breve: mais exercícios serão adicionados aqui."),
                    ),
                    Container(height: 150, color: Colors.grey[200], child: const Icon(Icons.videocam)),
                  ] else
                    ...exercisesInStep.map((exercise) => _SelectableExerciseTile(
                      exerciseName: exercise.name.split('-').first.trim(),
                      isSelected: viewModel.selectedExerciseIds.contains(exercise.id),
                      onChanged: (_) => viewModel.toggleExerciseSelection(exercise.id),
                    )),
                  CustomSolidButton(
                    text: viewModel.currentSelectionStepIndex == viewModel.customSteps.length - 1 ? 'CONCLUIR' : 'PRÓXIMO',
                    onPressed: isValid ? () => viewModel.handleNextSelectionStep(context) : () {},
                    color: isValid ? AppColors.darkGreen : Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SelectableExerciseTile extends StatelessWidget {
  final String exerciseName;
  final bool isSelected;
  final ValueChanged<bool?> onChanged;

  const _SelectableExerciseTile({
    required this.exerciseName,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;

    return Row(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: width * 0.15,
          width: width * 0.15,
          decoration: BoxDecoration(
            color: AppColors.lightBrown,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.play_arrow,
            color: Colors.white,
            size: width * 0.1,
          ),
        ),
        Flexible(
          flex: 1,
          child: Text(
            exerciseName,
            style: GoogleFonts.montserrat(
              fontSize: 24,
              color: AppColors.darkGreen,
            ),
            overflow: TextOverflow.fade,
          ),
        ),
        Transform.scale(
          scale: 1.5,
          child: Checkbox(
            value: isSelected,
            onChanged: onChanged,
            activeColor: AppColors.darkGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: const BorderSide(color: AppColors.darkGreen, width: 2),
          ),
        ),
      ],
    );
  }
}