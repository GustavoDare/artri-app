import 'package:artriapp/utils/index.dart';
import 'package:artriapp/view_models/index.dart';
import 'package:artriapp/views/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../utils/helpers/router_helper.dart';

class CustomExerciseIntroView extends StatelessWidget {
  const CustomExerciseIntroView({super.key});

  // Helper para ajustar a gramática da frase dependendo da categoria
  String _getPrefix(int count, String category) {
    String exercicioStr = count > 1 ? 'exercícios' : 'exercício';
    if (category == 'pernas') return 'Escolha $count $exercicioStr para as';
    if (category == 'braços') return 'Escolha $count $exercicioStr para os';
    if (category == 'tronco') return 'Escolha $count $exercicioStr para o';
    return 'Escolha $count $exercicioStr de';
  }

  Widget _buildChecklistItem(String prefix, String boldText) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          Icons.edit_square,
          color: AppColors.darkGreen,
          size: 40,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.montserrat(
                fontSize: 20,
                color: AppColors.darkGreen,
              ),
              children: [
                TextSpan(text: prefix),
                TextSpan(
                  text: ' $boldText',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PhysicalExercisesViewModel>(
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              spacing: 24,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Vamos começar a montar sua rotina de exercícios personalizada de hoje!\nClique para escolher os exercícios indicados abaixo:',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 8),

                // Geração dinâmica da lista com as quantidades corretas do ViewModel
                ...viewModel.customSteps.map((step) {
                  final count = step['requiredCount'] as int;
                  final category = step['title'] as String;
                  return _buildChecklistItem(_getPrefix(count, category), category);
                }),

                const SizedBox(height: 16),
                CustomSolidButton(
                  text: 'COMEÇAR',
                  onPressed: () {
                    var currentPath = RouterHelper.getUriFromContext(context).path;
                    var newPath = '$currentPath/selection';
                    context.go(newPath);
                  },
                  color: AppColors.darkGreen,
                  textStyle: GoogleFonts.montserrat(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}