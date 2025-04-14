import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_project/main.dart';
import '../utils/dialog_utils.dart';

/// ويدجت تمنع الخروج من الصفحة بدون تأكيد (عند الضغط على زر الرجوع)
class ConfirmExitPopScope extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? message;
  final String confirmText;
  final String cancelText;

  const ConfirmExitPopScope({
    super.key,
    required this.child,
    this.title = "هل تريد المغادرة؟",
    this.message = "قد تفقد التغييرات إذا لم تقم بحفظها",
    this.confirmText = "خروج",
    this.cancelText = "إلغاء",
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldExit = await DialogUtils.showConfirmDialog(
          context,
          title: title,
          message: message,
          confirmText: confirmText,
          cancelText: cancelText,
          confirmColor: Colors.red,
        );
        if (shouldExit == true) {
          Get.off(() => HomePage()); // Destroys QuizScreen and its controller
          // Navigator.of(context).pop();
        }
      },
      child: child,
    );
  }
}