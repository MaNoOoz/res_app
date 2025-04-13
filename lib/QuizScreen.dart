import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_project/quiz_controller.dart';

class QuizScreen extends StatelessWidget {
  QuizScreen({super.key});

  // final QuizController quizController = Get.find<QuizController>();
  final QuizController quizController = Get.put(QuizController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختبار المعلومات العامة', style: TextStyle(fontSize: 22)),
        actions: [
          IconButton(
            icon: const Icon(Icons.timer),
            onPressed: () {},
          ),
          Obx(() => Text(
            '${quizController.remainingSkips.value}',
            style: const TextStyle(fontSize: 18),
          )),
        ],
      ),
      body: Obx(() {
        if (quizController.quiz.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final currentQuestion = quizController.quiz.value!.questions[
        quizController.currentQuestionIndex.value];

        return Column(
          children: [
            // Question Progress
            LinearProgressIndicator(
              value: (quizController.currentQuestionIndex.value + 1) /
                  quizController.quiz.value!.questions.length,
            ),

            // Question Text
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                currentQuestion.text,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),

            // Answers Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3/2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: quizController.visibleAnswerIndices.length,
                itemBuilder: (context, index) {
                  final answerIndex = quizController.visibleAnswerIndices[index];
                  return ElevatedButton(
                    onPressed: () => quizController.answerQuestion(answerIndex),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[50],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      currentQuestion.answers[answerIndex],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                },
              ),
            ),

            // Lifelines Row
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 50/50 Lifeline
                  Obx(() => IconButton(
                    icon: const Icon(Icons.hourglass_bottom),
                    color: quizController.fiftyFiftyAvailable.value
                        ? Colors.blue
                        : Colors.grey,
                    onPressed: quizController.fiftyFiftyAvailable.value
                        ? quizController.useFiftyFifty
                        : null,
                  )),

                  // Time Boost
                  Obx(() => IconButton(
                    icon: const Icon(Icons.timer),
                    color: quizController.remainingTimeBoosts.value > 0
                        ? Colors.green
                        : Colors.grey,
                    onPressed: quizController.remainingTimeBoosts.value > 0
                        ? quizController.useTimeBoost
                        : null,
                  )),

                  // Skip Question
                  Obx(() => IconButton(
                    icon: const Icon(Icons.skip_next),
                    color: quizController.remainingSkips.value > 0
                        ? Colors.orange
                        : Colors.grey,
                    onPressed: quizController.remainingSkips.value > 0
                        ? quizController.useSkipQuestion
                        : null,
                  )),

                  // Watch Ad for Time
                  IconButton(
                    icon: const Icon(Icons.video_call),
                    color: Colors.purple,
                    onPressed: quizController.watchAdForTimeBoost,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}