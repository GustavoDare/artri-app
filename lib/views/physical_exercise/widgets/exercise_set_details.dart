import 'package:artriapp/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExerciseSetDetails extends StatelessWidget {
  final String exerciseDescription;

  const ExerciseSetDetails({super.key, required this.exerciseDescription});

  @override
  Widget build(BuildContext context) {
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
          Text(
            'Instruções/Observações:',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              color: AppColors.darkGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            exerciseDescription,
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
