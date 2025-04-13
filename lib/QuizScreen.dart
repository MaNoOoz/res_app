import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:quiz_project/quiz_controller.dart';
import 'package:quiz_project/utils/Constants.dart';

class QuizScreen extends StatelessWidget {
  QuizScreen({super.key});
  final QuizController quizController = Get.put(QuizController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Obx(() {
        if (quizController.quiz.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final currentQuestion = quizController.quiz.value!
            .questions[quizController.currentQuestionIndex.value];

        return SafeArea(
          child: Column(
            children: [

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Obx(() => IconButton(
                      icon: Icon(
                        quizController.isMusicOn.value
                            ? Icons.music_note
                            : Icons.music_off,
                        color: Colors.blue,
                      ),
                      onPressed: quizController.toggleMusic,
                    )),
                    Spacer(),
                    Obx(() => IconButton(
                      icon: Icon(
                        quizController.isSoundOn.value
                            ? Icons.volume_up
                            : Icons.volume_off,
                        color: Colors.blue,
                      ),
                      onPressed: quizController.toggleSound,
                    )),
                  ],
                ),
              ),
              // Top bar with timer, score, skips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: (quizController.currentQuestionIndex.value + 1) /
                          quizController.quiz.value!.questions.length,
                      color: PRIMARY_COLOR,
                      backgroundColor: Colors.grey.shade300,
                      minHeight: 6,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(() => Text(
                          'السؤال: ${quizController.currentQuestionIndex.value + 1} / ${quizController.quiz.value!.questions.length}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontFamily: '$font',
                            color: theme.colorScheme.onBackground,
                          ),
                        )),
                        Row(
                          children: [
                            Obx(() => IconButton(
                              icon: Icon(
                                quizController.isSoundOn.value
                                    ? Icons.volume_up
                                    : Icons.volume_off,
                                color: Colors.white,
                              ),
                              onPressed: quizController.toggleSound,
                            )),
                            Obx(() => IconButton(
                              icon: Icon(
                                quizController.isMusicOn.value
                                    ? Icons.music_note
                                    : Icons.music_off,
                                color: Colors.white,
                              ),
                              onPressed: quizController.toggleMusic,
                            )),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),

              // Question
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: theme.colorScheme.surface,
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      currentQuestion.text,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontFamily: '$font',
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),

              // Answers Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: GridView.builder(
                    itemCount: quizController.visibleAnswerIndices.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: size.width > 600 ? 3 : 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.2,
                    ),
                    itemBuilder: (context, index) {
                      final answerIndex = quizController.visibleAnswerIndices[index];
                      return ElevatedButton(
                        onPressed: () async{
                          quizController.answerQuestion(answerIndex);

                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          foregroundColor: theme.colorScheme.onPrimaryContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: Text(
                          currentQuestion.answers[answerIndex],
                          style: TextStyle(
                            fontFamily: '$font',
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Bottom bar: Score + Lifelines
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    // Score bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 6),
                            Obx(() => Text(
                              '${quizController.correctAnswers.value}',
                              style: TextStyle(fontFamily: '$font'),
                            )),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.cancel, color: Colors.red),
                            const SizedBox(width: 6),
                            Obx(() => Text(
                              '${quizController.wrongAnswers.value}',
                              style: TextStyle(fontFamily: '$font'),
                            )),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.timer, color: Colors.blue),
                            const SizedBox(width: 6),
                            Obx(() => Text(
                              '${quizController.remainingTime.value}s',
                              style: TextStyle(fontFamily: '$font'),
                            )),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Lifelines
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _lifelineButton(
                          icon: Icons.timer,
                          label: 'وقت إضافي',
                          available: quizController.remainingTimeBoosts.value > 0,
                          onTap: quizController.useTimeBoost,
                        ),
                        _lifelineButton(
                          icon: Icons.filter_2,
                          label: '50/50',
                          available: quizController.fiftyFiftyAvailable.value,
                          onTap: quizController.useFiftyFifty,
                        ),
                        _lifelineButton(
                          icon: Icons.skip_next,
                          label: 'تخطي',
                          available: quizController.remainingSkips.value > 0,
                          onTap: quizController.useSkipQuestion,
                        ),
                        _lifelineButton(
                          icon: Icons.video_library,
                          label: 'إعلان',
                          available: true,
                          onTap: quizController.watchAdForTimeBoost,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _lifelineButton({
    required IconData icon,
    required String label,
    required bool available,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 30),
          color: available ? Colors.white : Colors.grey,
          onPressed: available ? onTap : null,
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontFamily: '$font',
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
