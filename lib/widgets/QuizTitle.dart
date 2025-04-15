import 'package:flutter/material.dart';

class QuizTitle extends StatelessWidget {
  final String title;
  final Color? textColor;
  final double? fontSize;
  final TextAlign? textAlign;
  final int? maxLines;

  const QuizTitle({
    super.key,
    required this.title,
    this.textColor,
    this.fontSize,
    this.textAlign,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive font size calculation
    final calculatedFontSize =
        fontSize ??
        (screenWidth < 350
            ? 20.0
            : screenWidth < 600
            ? 24.0
            : 28.0);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: 16,
      ),
      child: Text(
        title,
        textAlign: textAlign ?? TextAlign.center,
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
        style: TextStyle(
          color: textColor ?? Theme.of(context).primaryColor,
          fontSize: calculatedFontSize,
          fontWeight: FontWeight.bold,
          height: 1.3,
        ),
      ),
    );
  }
}
