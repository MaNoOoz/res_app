class Quiz {
  final List<Question> questions;
  final Lifelines lifelines;

  Quiz({required this.questions, required this.lifelines});

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      questions: List<Question>.from(
          json['questions'].map((x) => Question.fromJson(x))),
      lifelines: Lifelines.fromJson(json['lifelines']),
    );
  }
}

class Question {
  final String text;
  final List<String> answers;
  final int correctIndex;
  final String? category;

  Question({
    required this.text,
    required this.answers,
    required this.correctIndex,
    this.category,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      text: json['q'],
      answers: List<String>.from(json['a']),
      correctIndex: json['correct'],
      category: json['category'],
    );
  }

  // Helper method for 50/50 lifeline
  List<String> getFiftyFiftyOptions() {
    final wrongAnswers = answers
        .asMap()
        .entries
        .where((e) => e.key != correctIndex)
        .map((e) => e.value)
        .toList()..shuffle();

    return [
      answers[correctIndex],
      wrongAnswers.first,
    ]..shuffle();
  }
}

class Lifelines {
  final bool fiftyFifty;
  final int timeBoost;
  final int skipQuestion;

  Lifelines({
    required this.fiftyFifty,
    required this.timeBoost,
    required this.skipQuestion,
  });

  factory Lifelines.fromJson(Map<String, dynamic> json) {
    return Lifelines(
      fiftyFifty: json['50_50'],
      timeBoost: json['time_boost'],
      skipQuestion: json['skip_question'],
    );
  }
}