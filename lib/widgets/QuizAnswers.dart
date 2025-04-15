import 'package:flutter/material.dart';

class QuizAnswers extends StatelessWidget {
  final List<String> answers;
  final ValueChanged<int> onAnswerSelected;
  final int? selectedAnswerIndex;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? textColor;
  final double? fontSize;

  const QuizAnswers({
    super.key,
    required this.answers,
    required this.onAnswerSelected,
    this.selectedAnswerIndex,
    this.selectedColor,
    this.unselectedColor,
    this.textColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final isPortrait = screenSize.height > screenSize.width;

    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonWidth = constraints.maxWidth * 0.9;
        final buttonHeight =
            isPortrait
                ? constraints.maxHeight * 0.12
                : constraints.maxHeight * 0.2;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < answers.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SizedBox(
                  width: buttonWidth,
                  height: buttonHeight.clamp(48, 80),
                  child: ElevatedButton(
                    onPressed: () => onAnswerSelected(i),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          selectedAnswerIndex == i
                              ? selectedColor ?? Theme.of(context).primaryColor
                              : unselectedColor ?? Theme.of(context).cardColor,
                      foregroundColor:
                          textColor ??
                          (selectedAnswerIndex == i
                              ? Colors.white
                              : Theme.of(context).textTheme.bodyLarge?.color),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      textStyle: TextStyle(fontSize: 48),
                    ),
                    child: Text(
                      answers[i],
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
