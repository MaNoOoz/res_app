import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../models/quiz_model.dart';

class QuizRepository {
  Future<Quiz> loadArabicQuiz() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/quiz_ar.json');
      return Quiz.fromJson(json.decode(jsonString));
    } catch (e) {
      Get.snackbar('Error', 'Failed to load quiz data');
      throw Exception('Failed to load quiz: $e');
    }
  }
}