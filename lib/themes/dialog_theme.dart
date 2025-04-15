import 'package:flutter/material.dart';

class AppDialogTheme {
  static DialogThemeData dialogTheme(BuildContext context) {
    return Theme.of(context).dialogTheme.copyWith(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  static AlertDialog alertDialogStyle(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
