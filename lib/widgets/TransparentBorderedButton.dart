import 'package:flutter/material.dart';

class TransparentBorderedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double borderRadius;
  final double borderWidth;
  final double width;
  final EdgeInsetsGeometry padding;
  final TextStyle? textStyle;

  const TransparentBorderedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.borderRadius = 20.0,
    this.borderWidth = 2.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.textStyle,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,

      style: OutlinedButton.styleFrom(
        minimumSize: Size(width, 100),
        backgroundColor: Colors.transparent,
        side: BorderSide(color: Colors.white, width: borderWidth),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: padding,
      ),
      child: Text(
        text,
        style:
            textStyle ??
            Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
