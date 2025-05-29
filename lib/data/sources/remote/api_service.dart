import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import '../../../core/app_core.dart';
import '../../../core/models.dart';
import '../../../main2.dart';


class ApiService extends GetxService {
  final String _baseUrl = AppConfig.instance.clientSettings.baseApiUrl;
  final String _sheetId = AppConfig.instance.clientSettings.googleSheetId;
  final String _menuSheetName = AppConfig.instance.clientSettings.menuSheetName;
  final String _categoriesSheetName = AppConfig.instance.clientSettings.categoriesSheetName;
  final String _configSheetName = AppConfig.instance.clientSettings.configSheetName;
  final String _clientId = AppConfig.instance.clientSettings.clientId;

  Future<List<MenuItem>> fetchMenuItems() async {
    final url = Uri.parse('$_baseUrl?sheet=$_menuSheetName&sheetId=$_sheetId');
    Get.log('Fetching menu items from: $url');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        Get.log('Fetching menu items from: ${response.body}');

        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => MenuItem.fromJson(json)).toList();
      }

      else {
        Get.log('Failed to load menu items. Status code: ${response.statusCode}');
        Get.log('Response body: ${response.body}');
        throw Exception('Failed to load menu items');
      }
    } catch (e) {
      Get.log('Error fetching menu items: $e');
      throw Exception('Failed to connect to API: $e');
    }
  }

  Future<List<Category>> fetchCategories() async {
    final url = Uri.parse('$_baseUrl?sheet=$_categoriesSheetName&sheetId=$_sheetId');
    Get.log('Fetching categories from: $url');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Category.fromJson(json)).toList();
      } else {
        Get.log('Failed to load categories. Status code: ${response.statusCode}');
        Get.log('Response body: ${response.body}');
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      Get.log('Error fetching categories: $e');
      throw Exception('Failed to connect to API: $e');
    }
  }

  // هذه الدالة ستستخدم لجلب إعدادات العميل الخاصة بهذا التطبيق
  Future<Map<String, dynamic>?> fetchClientConfig() async {
    final url = Uri.parse('$_baseUrl?sheet=$_configSheetName&sheetId=$_sheetId&clientId=$_clientId');
    Get.log('Fetching client config from: $url');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Client_Config ترجع كائن واحد وليس قائمة
        Map<String, dynamic>? jsonMap = json.decode(response.body);
        return jsonMap;
      } else {
        Get.log('Failed to load client config. Status code: ${response.statusCode}');
        Get.log('Response body: ${response.body}');
        throw Exception('Failed to load client config');
      }
    } catch (e) {
      Get.log('Error fetching client config: $e');
      throw Exception('Failed to connect to API: $e');
    }
  }
}