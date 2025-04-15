import 'package:flutter/material.dart';

import '../widgets/dialogs/share_dialog.dart';

class DialogUtils {
  // ====================== ديالوج تأكيد ======================
  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    String? title,
    String? message,
    String confirmText = "نعم",
    String cancelText = "إلغاء",
    Color? confirmColor,
  }) async {
    return await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: title != null ? Text(title) : null,
            content: message != null ? Text(message) : null,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(cancelText),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  confirmText,
                  style: TextStyle(color: confirmColor ?? Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  // ====================== ديالوج خطأ ======================
  static Future<void> showErrorDialog(
    BuildContext context, {
    String? title,
    required String message,
    String buttonText = "حسناً",
  }) async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: title != null ? Text(title) : const Text("حدث خطأ!"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(buttonText),
              ),
            ],
          ),
    );
  }

  // ====================== ديالوج نجاح ======================
  static Future<void> showSuccessDialog(
    BuildContext context, {
    String? title,
    required String message,
    String buttonText = "تم",
  }) async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            icon: const Icon(Icons.check_circle, color: Colors.green),
            title: title != null ? Text(title) : const Text("تم بنجاح!"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(buttonText),
              ),
            ],
          ),
    );
  }

  // ====================== ديالوج تحميل ======================
  static Future<void> showLoadingDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // لا يختفي عند الضغط خارج الديالوج
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  // ====================== ديالوج منبثق من الأسفل (Bottom Sheet) ======================
  static Future<void> showBottomSheetDialog(
    BuildContext context, {
    required Widget child,
  }) async {
    return showModalBottomSheet(
      context: context,
      builder:
          (context) =>
              Padding(padding: const EdgeInsets.all(16.0), child: child),
    );
  }

  // ديالوج المشاركة
  static Future<void> showShareDialog(
    BuildContext context, {
    required String shareContent,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => ShareDialog(content: shareContent),
    );
  }

  // ديالوج اختيار التاريخ
  static Future<DateTime?> showDatePickerDialog(
    BuildContext context, {
    DateTime? initialDate,
  }) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
