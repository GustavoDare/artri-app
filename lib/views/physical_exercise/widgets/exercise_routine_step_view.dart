import 'package:artriapp/utils/index.dart';
import 'package:artriapp/view_models/index.dart';
import 'package:artriapp/views/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ExerciseRoutineStepView extends StatelessWidget {
  const ExerciseRoutineStepView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PhysicalExercisesViewModel>(
      builder: (context, viewModel, child) {
        var exercise = viewModel.currentExercise;

        bool hasVideo = exercise != null && exercise.tutorialLink.isNotEmpty;
        YoutubePlayerController? videoController;

        if (hasVideo) {
          videoController = YoutubePlayerController(
            initialVideoId: YoutubePlayer.convertUrlToId(exercise.tutorialLink) ?? 'IxX_QHay02M',
            flags: const YoutubePlayerFlags(
              autoPlay: false,
              controlsVisibleAtStart: true,
            ),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: Column(
              spacing: 16,
              children: [
                if (hasVideo && videoController != null)
                  YoutubePlayer(controller: videoController)
                else
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.videocam_off, size: 64, color: Colors.grey[600]),
                        const SizedBox(height: 8),
                        Text(
                          "Vídeo não disponível",
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      ],
                    ),
                  ),

                SessionTitle(title: exercise?.name.split('-').first.trim() ?? ''),
                ExerciseSetProperties(
                  details: exercise!.details,
                ),
                ExerciseSetDetails(
                  exerciseDescription: exercise.description,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}