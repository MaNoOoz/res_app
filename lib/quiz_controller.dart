import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:quiz_project/widgets/dialogs/quiz_finsihed_dialoag.dart';

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
  final RxInt correctAnswers = 0.obs;
  final RxInt wrongAnswers = 0.obs;
  final RxInt remainingTime = 10.obs; // 10 seconds per question
  Timer? _timer;
  AudioPlayer bgMusic = AudioPlayer();
  AudioPlayer sfxPlayer = AudioPlayer();
  var isMusicOn = true.obs;
  var isSoundOn = true.obs;
  void startMusic() async {
    if (isMusicOn.value) {
      await bgMusic.setReleaseMode(ReleaseMode.loop);
      await bgMusic.play(AssetSource('sounds/bg_music.mp3'));
    }
  }

  void toggleMusic() {
    isMusicOn.value = !isMusicOn.value;
    if (isMusicOn.value) {
      bgMusic.resume();
    } else {
      bgMusic.pause();
    }
  }
  void toggleSound() {
    isSoundOn.value = !isSoundOn.value;
  }
  void playCorrectSound() async{
    if (isSoundOn.value) {
      await sfxPlayer.stop();
      sfxPlayer.play(AssetSource('sounds/correct.mp3'));
    }
  }

  void playWrongSound() async{
    if (isSoundOn.value) {
      await sfxPlayer.stop();

      sfxPlayer.play(AssetSource('sounds/wrong.mp3'));
    }
  }
  @override
  void onInit() {
    loadQuiz();
    super.onInit();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<void> loadQuiz() async {
    quiz.value = await _repository.loadArabicQuiz();
    correctAnswers.value = 0;
    wrongAnswers.value = 0;
    _initLifelines();
    _updateVisibleAnswers();
    startTimer();
    startMusic();
  }

  void startTimer() {
    _timer?.cancel(); // cancel any existing timer
    remainingTime.value = 10;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime.value > 0) {
        remainingTime.value--;
      } else {
        timer.cancel();
        moveToNextQuestion(); // Auto-skip if time runs out
      }
    });
  }

  void useTimeBoost() {
    if (remainingTimeBoosts.value > 0) {
      remainingTimeBoosts.value--;
      remainingTime.value += 10; // Add 10 seconds
      update();
    }
  }

  void _updateVisibleAnswers() {
    final question = quiz.value?.questions[currentQuestionIndex.value];
    if (question == null) return;

    visibleAnswerIndices.value = List.generate(
      question.answers.length,
      (index) => index,
    );
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
        final incorrectIndices =
            List.generate(question.answers.length, (i) => i)
              ..remove(correct)
              ..shuffle();

        // Pick only one incorrect + the correct one
        visibleAnswerIndices.value = [correct, incorrectIndices.first]
          ..shuffle();
      }

      fiftyFiftyAvailable.value = false;
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
    if (quiz.value != null &&
        currentQuestionIndex.value < quiz.value!.questions.length - 1) {
      currentQuestionIndex.value++;
      _updateVisibleAnswers();
      startTimer();
    } else {
      _timer?.cancel();
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.dialog(
          QuizFinishedDialog(
            totalQuestions: quiz.value!.questions.length,
            correctAnswers: correctAnswers.value,
          ),
        );
      });
    }
    update();
  }

  void moveToLastQuestion() {
    if (quiz.value != null) {
      currentQuestionIndex.value = quiz.value!.questions.length - 1;
      _updateVisibleAnswers();
      startTimer();
      update();
    }
  }

  void answerQuestion(int index) async{
    final currentQuestion = quiz.value?.questions[currentQuestionIndex.value];
    if (currentQuestion == null) return;

    final bool isCorrect = index == currentQuestion.correctIndex;
    final bool isWrong = index != currentQuestion.correctIndex;

    if (isCorrect) {
      correctAnswers.value++;
    } else if (isWrong) {
      wrongAnswers.value++;
    }

    Logger().d('User selected answer: ${currentQuestion.answers[index]}');
    Logger().d(isCorrect ? 'Correct answer!' : 'Wrong answer.');
    await Future.delayed(Duration(milliseconds: 500));
    moveToNextQuestion();
  }
}
