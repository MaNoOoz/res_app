import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

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

  Future<Quiz> loadArabicQuizFromDrive() async {
    const String fileId = '18LjgwG9g3msosWB-2cDGTdWLIbSG6FGP'; // Replace with your real ID
    final String url = 'https://drive.google.com/uc?export=download&id=$fileId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return Quiz.fromJson(json.decode(response.body));
      } else {
        Get.snackbar('Error', 'Failed to fetch quiz data');
        throw Exception('Failed to load quiz from Drive');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error loading quiz data');
      throw Exception('Error fetching from Google Drive: $e');
    }
  }

}