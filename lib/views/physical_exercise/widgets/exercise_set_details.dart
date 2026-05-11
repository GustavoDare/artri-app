import 'package:artriapp/models/api_responses/index.dart';
import 'package:artriapp/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExerciseSetDetails extends StatelessWidget {
  final ExerciseDetails details;

  const ExerciseSetDetails({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    final List<Widget> equipmentChildren = [];

    if (details.equipment != null) {
      equipmentChildren.addAll([
        Text(
          'Equipamento:',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            color: AppColors.darkGreen,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '${details.equipment}',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
      ]);
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      constraints: BoxConstraints(
        minHeight: 250,
        minWidth: double.infinity,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkGreenSurface,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        spacing: 6,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...equipmentChildren,
          Text(
            'Instruções/Observações:',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              color: AppColors.darkGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'Faça o exercício devagar, controlando o movimento e a respiração. Mantenha a postura correta para evitar lesões.',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
