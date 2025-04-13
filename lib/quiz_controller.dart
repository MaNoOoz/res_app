import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../data/sources/local/quiz_repository.dart';
import 'models/quiz_model.dart';

class QuizController extends GetxController {
  final QuizRepository _repository = QuizRepository();
  final Rx<Quiz?> quiz = Rx<Quiz?>(null);
  final RxInt currentQuestionIndex = 0.obs;
  final RxInt remainingSkips = 0.obs;
  final RxInt remainingTimeBoosts = 0.obs;
  final RxBool fiftyFiftyAvailable = false.obs;
  final RxList<int> visibleAnswerIndices = <int>[].obs;
  @override
  void onInit() {
    loadQuiz();
    super.onInit();
  }

  Future<void> loadQuiz() async {
    quiz.value = await _repository.loadArabicQuiz();
    _initLifelines();
    _updateVisibleAnswers(); // <-- show all answers initially
  }
  void _updateVisibleAnswers() {
    final question = quiz.value?.questions[currentQuestionIndex.value];
    if (question == null) return;

    visibleAnswerIndices.value = List.generate(question.answers.length, (index) => index);
  }


  void _initLifelines() {
    if (quiz.value != null) {
      fiftyFiftyAvailable.value = quiz.value!.lifelines.fiftyFifty;
      remainingTimeBoosts.value = quiz.value!.lifelines.timeBoost;
      remainingSkips.value = quiz.value!.lifelines.skipQuestion;
    }
  }

  // Lifeline methods
  void useFiftyFifty() {
    if (fiftyFiftyAvailable.value) {
      final question = quiz.value?.questions[currentQuestionIndex.value];
      if (question != null) {
        final correct = question.correctIndex;
        final incorrectIndices = List.generate(question.answers.length, (i) => i)
          ..remove(correct)
          ..shuffle();

        // Pick only one incorrect + the correct one
        visibleAnswerIndices.value = [correct, incorrectIndices.first]..shuffle();
      }

      fiftyFiftyAvailable.value = false;
      update();
    }
  }


  void useTimeBoost() {
    if (remainingTimeBoosts.value > 0) {
      remainingTimeBoosts.value--;
      // Add time boost logic when timer is implemented
      update();
    }
  }

  void useSkipQuestion() {
    if (remainingSkips.value > 0) {
      remainingSkips.value--;
      moveToNextQuestion();
    }
  }

  // Ad integration placeholder
  Future<void> watchAdForTimeBoost() async {
    // Implement ad watching logic
    remainingTimeBoosts.value++;
    update();
  }
  void moveToNextQuestion() {
    if (quiz.value != null && currentQuestionIndex.value < quiz.value!.questions.length - 1) {
      currentQuestionIndex.value++;
      _updateVisibleAnswers(); // Reset visible answers
    } else {
      print('Quiz completed!');
    }
    update();
  }


  void answerQuestion(int index) {
    final currentQuestion = quiz.value?.questions[currentQuestionIndex.value];
    if (currentQuestion == null) return;

    final bool isCorrect = index == currentQuestion.correctIndex;

    Logger().d('User selected answer: ${currentQuestion.answers[index]}');
    Logger().d(isCorrect ? 'Correct answer!' : 'Wrong answer.');

    // Optionally, you can store this result somewhere or delay before moving on
    // Automatically move to next question (or wait for user input)
    moveToNextQuestion();
  }

}