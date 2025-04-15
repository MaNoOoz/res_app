import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_project/main.dart';

import '../../quiz_controller.dart';

class QuizFinishedDialog extends StatelessWidget {
  final int totalQuestions;
  final int correctAnswers;

  const QuizFinishedDialog({
    super.key,
    required this.totalQuestions,
    required this.correctAnswers,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'تم الانتهاء!',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('عدد الأسئلة: $totalQuestions'),
          const SizedBox(height: 8),
          Text('إجابات صحيحة: $correctAnswers'),
          const SizedBox(height: 8),
          Text('إجابات خاطئة: ${totalQuestions - correctAnswers}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.find<QuizController>().resetGame(); // restart quiz
            Get.offAll(HomePage());
          },
          child: const Text('إنهاء'),
        ),
        TextButton(
          onPressed: () {
            Get.find<QuizController>().resetGame(); // restart quiz
            Get.offAll(HomePage());
          },
          child: const Text('إعادة المحاولة'),
        ),
      ],
    );
  }
}
