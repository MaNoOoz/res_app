import 'dart:async';
import 'dart:convert';

// import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:quiz_project/widgets/dialogs/quiz_finsihed_dialoag.dart';

import '../data/sources/local/quiz_repository.dart';
import 'AdController.dart';
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
  // AudioPlayer bgMusic = AudioPlayer();
  // AudioPlayer sfxPlayer = AudioPlayer();
  var isMusicOn = true.obs;
  var isSoundOn = true.obs;
  final storage = GetStorage();

  @override
  void onInit() {
    loadQuiz();
    resetGame();
    super.onInit();
  }

  @override
  void onClose() {
    _timer?.cancel();
    // bgMusic.dispose();
    // sfxPlayer.dispose();
    resetGame();

    super.onClose();
  }

  bool _isNewerVersion(String remote, String local) {
    final r = remote.split('.').map(int.parse).toList();
    final l = local.split('.').map(int.parse).toList();

    for (int i = 0; i < r.length; i++) {
      if (i >= l.length || r[i] > l[i]) return true;
      if (r[i] < l[i]) return false;
    }
    return false;
  }

  Future<void> checkAndLoadQuizData() async {
    try {
      final remoteQuiz =
          await _repository.loadArabicQuizFromDrive(); // Load from Drive
      final localVersion = storage.read('quiz_version') ?? '0.0.0';
      final remoteVersion = remoteQuiz.version ?? '0.0.0';

      if (_isNewerVersion(remoteVersion, localVersion)) {
        Logger().d('New version found: $remoteVersion');
        // New version found, update local storage
        storage.write('quiz_version', remoteVersion);
        storage.write('quiz_data', json.encode(remoteQuiz.toJson()));
        quiz.value = remoteQuiz;
      } else {
        Logger().d('New version Not found: $remoteVersion');

        // No update found, try local cached version
        final savedJson = storage.read('quiz_data');
        if (savedJson != null) {
          quiz.value = Quiz.fromJson(json.decode(savedJson));
        } else {
          // Fallback to asset if no cache found
          quiz.value = await _repository.loadArabicQuiz();
        }
      }
    } catch (e) {
      // Error loading from Drive or storage, fallback to local asset
      quiz.value = await _repository.loadArabicQuiz();
    }
  }

  // void startMusic() async {
  //   if (isMusicOn.value) {
  //     await bgMusic.setReleaseMode(ReleaseMode.loop);
  //     await bgMusic.play(AssetSource('sounds/bg_music.mp3'));
  //   }
  // }
  //
  // void toggleMusic() {
  //   isMusicOn.value = !isMusicOn.value;
  //   if (isMusicOn.value) {
  //     bgMusic.resume();
  //   } else {
  //     bgMusic.pause();
  //   }
  // }

  void toggleSound() {
    isSoundOn.value = !isSoundOn.value;
  }

  // Future<void> playCorrectSound() async {
  //   if (isSoundOn.value) {
  //     await sfxPlayer.stop();
  //     sfxPlayer.play(AssetSource('sounds/correct.mp3'));
  //   }
  // }
  //
  // Future<void> playWrongSound() async {
  //   if (isSoundOn.value) {
  //     await sfxPlayer.stop();
  //
  //     sfxPlayer.play(AssetSource('sounds/wrong.mp3'));
  //   }
  // }

  void resetGame() {
    quiz.value?.questions.shuffle(); // this randomizes the list
    currentQuestionIndex.value = 0;
    correctAnswers.value = 0;
    wrongAnswers.value = 0;
    // reset any other state
  }

  Future<void> loadQuiz() async {
    await checkAndLoadQuizData();
    quiz.value = await _repository.loadArabicQuiz();
    correctAnswers.value = 0;
    wrongAnswers.value = 0;
    _initLifelines();
    _updateVisibleAnswers();
    // startMusic();
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
  // Add these new variables for ad state management
  final RxBool isAdShowing = false.obs;
  int? pausedTimerValue; // Stores timer value when paused

  // Modified timer methods to handle pausing
  void pauseTimer() {
    Logger().e('pauseTimer');
    if (_timer != null && _timer!.isActive) {
      pausedTimerValue = remainingTime.value;
      _timer!.cancel();
      isAdShowing.value = true;
    }
  }

  void resumeTimer() {
    if (pausedTimerValue != null) {
      remainingTime.value = pausedTimerValue!;
      pausedTimerValue = null;
    }
    startTimer(); // This will restart the timer with remaining time
    isAdShowing.value = false;
  }

  // Enhanced ad watching method
  Future<void> watchAdForTimeBoost() async {
    if (remainingTime.value <= 0) {
      Get.snackbar('Notice', 'Question already timed out');
      return;
    }

    pauseTimer(); // Pause timer when ad starts

    final AdController adController = Get.find();

    try {
      adController.setAdLoading(true);
      update();

      final bool adCompleted = await adController.showRewardedAd();

      if (adCompleted) {
        remainingTimeBoosts.value++;
        Get.snackbar('Success', 'You earned +10 time boost!');
      } else {
        Get.snackbar('Notice', 'Please watch the full ad to earn rewards');
      }
    } catch (e) {
      Logger().e('Ad error: $e');
      Get.snackbar('Error', 'Failed to show ad. Please try again.');
    } finally {
      adController.setAdLoading(false);
      // resumeTimer(); // Resume timer when ad finishes (success or failure)
      update();
    }
  }

  Future<void> watchAdForTimeBoost2() async {
    if (remainingTime.value <= 0) {
      Get.snackbar('Notice', 'Question already timed out');
      return;
    }

    pauseTimer(); // Pause timer when ad starts

    final AdController adController = Get.find(); // Use find instead of put

    try {
      final adShown = await adController.showInterstitialAd();

      if (adShown) {
        remainingTime.value =
            60; // Add 20 seconds (was +30 but snackbar says +10)
        Get.snackbar('Success', 'You earned +20 seconds!');
      } else {
        Get.snackbar('Notice', 'Ad not available');
      }
    } catch (e) {
      Logger().e('Ad error: $e');
      Get.snackbar('Error', 'Failed to show ad. Please try again.');
    } finally {
      // resumeTimer(); // Resume timer when ad finishes
    }
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

  void answerQuestion(int index) async {
    final currentQuestion = quiz.value?.questions[currentQuestionIndex.value];
    if (currentQuestion == null) return;

    final bool isCorrect = index == currentQuestion.correctIndex;
    final bool isWrong = index != currentQuestion.correctIndex;

    if (isCorrect) {
      correctAnswers.value++;
      // await playCorrectSound(); // 🔥 Await here
    } else if (isWrong) {
      wrongAnswers.value++;
      // await playWrongSound(); // 🔥 Await here
    }

    Logger().d('User selected answer: ${currentQuestion.answers[index]}');
    Logger().d(isCorrect ? 'Correct answer!' : 'Wrong answer.');
    await Future.delayed(Duration(milliseconds: 500));
    moveToNextQuestion();
  }
}
