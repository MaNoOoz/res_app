import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../../../core/app_core.dart';
import '../../../core/models.dart';

class ApiService extends GetxService {
  final Logger _logger = Logger();
  final _cache = <String, dynamic>{};

  // Cache duration for different types of data
  static const Duration _cacheTimeout = Duration(minutes: 5);
  final Map<String, DateTime> _cacheTimestamps = {};

  Uri _buildAppScriptUrl({
    required String action,
    required String googleAppScriptUrl,
    required String googleSheetId,
    String? sheetName,
    String? clientId,
  }) {
    final queryParams = <String, String>{
      'action': action,
      'google_sheet_id': googleSheetId,
    };

    if (sheetName != null && sheetName.isNotEmpty) {
      queryParams['sheet_name'] = sheetName;
    }
    if (clientId != null && clientId.isNotEmpty) {
      queryParams['client_id'] = clientId;
    }

    // Add cache-buster for web to prevent caching issues
    if (kIsWeb) {
      queryParams['t'] = DateTime.now().millisecondsSinceEpoch.toString();
    }

    return Uri.parse(googleAppScriptUrl).replace(queryParameters: queryParams);
  }

  // Enhanced cache management
  bool _isCacheValid(String key) {
    if (!_cacheTimestamps.containsKey(key)) return false;

    final cacheTime = _cacheTimestamps[key]!;
    final now = DateTime.now();
    return now.difference(cacheTime) < _cacheTimeout;
  }

  void _updateCache(String key, dynamic data) {
    _cache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
  }

  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
    _logger.i('Cache cleared');
  }

  Future<Map<String, dynamic>> fetchClientConfig({
    required String clientId,
    required String defaultAppScriptUrl,
    required String defaultClientConfigSheetId,
    required String configSheetName,
  }) async {
    final cacheKey = 'client_config_$clientId';

    // Check cache first
    if (_isCacheValid(cacheKey)) {
      _logger.d('Returning cached client config for: $clientId');
      return _cache[cacheKey];
    }

    final uri = _buildAppScriptUrl(
      action: 'getClientConfig',
      googleAppScriptUrl: defaultAppScriptUrl,
      googleSheetId: defaultClientConfigSheetId,
      sheetName: configSheetName,
      clientId: clientId,
    );

    try {
      _logger.i('Fetching client config from: ${uri.toString()}');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      _logger.d('Client config response status: ${response.statusCode}');
      _logger.d('Client config response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Handle Google Script errors
        if (data is Map && data.containsKey('error')) {
          throw Exception('Google Script error: ${data['error']}');
        }

        _updateCache(cacheKey, data);
        return data;
      } else if (response.statusCode == 404) {
        throw Exception('Client configuration not found (404)');
      } else {
        throw Exception('HTTP error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      _logger.e('Client config fetch failed', error: e);
      rethrow;
    }
  }

  Future<List<MenuItem>> fetchMenuItems() async {
    if (AppConfig.instance.clientSettings.googleAppScriptUrl == null) {
      throw Exception('Google App Script URL not configured');
    }

    return _fetchData<MenuItem>(
      action: 'getMenuItems',
      sheetNameParam: (settings) => settings.menuSheetName,
      fromJson: MenuItem.fromJson,
      fallbackSheetName: 'menu',
    );
  }

  Future<List<Category>> fetchCategories() async {
    Logger().d('fetchCategories : $fetchCategories');

    return _fetchData<Category>(
      action: 'getCategories',
      sheetNameParam: (settings) => settings.categoriesSheetName,
      fromJson: Category.fromJson,
      fallbackSheetName: 'category',
    );
  }

  Future<List<T>> _fetchData<T>({
    required String action,
    required String Function(ClientSpecificSettings) sheetNameParam,
    required T Function(Map<String, dynamic>) fromJson,
    required String fallbackSheetName,
  }) async {
    final currentAppConfig = AppConfig.instance;
    final settings = currentAppConfig.clientSettings;

    // Validate critical parameters
    if (settings.googleSheetId.isEmpty) {
      throw Exception('Google Sheet ID is not configured');
    }

    if (settings.googleAppScriptUrl == null ||
        settings.googleAppScriptUrl!.isEmpty) {
      throw Exception('Google App Script URL is not configured');
    }

    final sheetName = sheetNameParam(settings).isNotEmpty
        ? sheetNameParam(settings)
        : fallbackSheetName;

    // Check cache
    final cacheKey = '${action}_${sheetName}';
    if (_isCacheValid(cacheKey)) {
      _logger.d('Returning cached data for: $action');
      return List<T>.from(_cache[cacheKey]);
    }

    final uri = _buildAppScriptUrl(
      action: action,
      googleAppScriptUrl: settings.googleAppScriptUrl!,
      googleSheetId: settings.googleSheetId,
      sheetName: sheetName,
    );

    try {
      _logger.i('Fetching $action data from: ${uri.toString()}');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      _logger.d('$action response status: ${response.statusCode}');
      _logger.d('$action response body length: ${response.body.length}');

      if (response.statusCode == 200) {
        final responseBody = response.body;

        // Check if response is empty
        if (responseBody.isEmpty) {
          _logger.w('Empty response for $action');
          return [];
        }

        final decoded = json.decode(responseBody);

        // Handle error responses from Google Apps Script
        if (decoded is Map && decoded.containsKey('error')) {
          throw Exception('Google Script error: ${decoded['error']}');
        }

        // Ensure we have a list
        if (decoded is! List) {
          throw Exception('Expected list response, got: ${decoded.runtimeType}');
        }

        final List<dynamic> data = decoded;

        // Handle empty responses
        if (data.isEmpty) {
          _logger.w('No data found for $action in sheet: $sheetName');
          return [];
        }

        final result = data.map<T>((json) {
          if (json is! Map<String, dynamic>) {
            throw Exception('Invalid JSON format for $action');
          }
          return fromJson(json);
        }).toList();

        // Cache the result
        _updateCache(cacheKey, result);

        _logger.i('Successfully fetched ${result.length} items for $action');
        return result;

      } else {
        throw Exception('Failed to load data: ${response.statusCode} - ${response.body}');
      }
    } on http.ClientException catch (e) {
      _logger.e('Network error fetching $action', error: e);
      throw Exception('Network error: ${e.message}');
    } on FormatException catch (e) {
      _logger.e('JSON parsing error for $action', error: e);
      throw Exception('Data format error: ${e.message}');
    } catch (e) {
      _logger.e('Unexpected error fetching $action', error: e);
      rethrow;
    }
  }

  // Method to test connectivity
  Future<bool> testConnection() async {
    try {
      final settings = AppConfig.instance.clientSettings;
      if (settings.googleAppScriptUrl == null) {
        return false;
      }

      final uri = _buildAppScriptUrl(
        action: 'getCategories',
        googleAppScriptUrl: settings.googleAppScriptUrl!,
        googleSheetId: settings.googleSheetId,
        sheetName: 'category',
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      _logger.e('Connection test failed', error: e);
      return false;
    }
  }

  // Debug method to log current configuration
  void debugConfig() {
    final settings = AppConfig.instance.clientSettings;
    _logger.d('=== API Service Configuration ===');
    _logger.d('Google App Script URL: ${settings.googleAppScriptUrl}');
    _logger.d('Google Sheet ID: ${settings.googleSheetId}');
    _logger.d('Menu Sheet Name: ${settings.menuSheetName}');
    _logger.d('Categories Sheet Name: ${settings.categoriesSheetName}');
    _logger.d('================================');
  }
}