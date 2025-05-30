import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../utils/Constants.dart'; // Make sure this path is correct for BASE_CONFIG_FILE

/// Represents client-specific configurations fetched dynamically.
class ClientSpecificSettings {
  final String clientId;
  final String cafeRestaurantName;
  final Color primaryColor;
  final String googleSheetId;
  final String menuSheetName;
  final String categoriesSheetName;
  final String configSheetName;
  final String? googleAppScriptUrl;
  final String? contactEmail;
  final String? contactPhone;
  final String? websiteUrl;
  final Map<String, String>? socialMediaLinks;

  ClientSpecificSettings({
    required this.clientId,
    required this.cafeRestaurantName,
    required this.primaryColor,
    required this.googleSheetId,
    required this.menuSheetName,
    required this.categoriesSheetName,
    required this.configSheetName,
    this.googleAppScriptUrl,
    this.contactEmail,
    this.contactPhone,
    this.websiteUrl,
    this.socialMediaLinks,
  });

  factory ClientSpecificSettings.fromJson(Map<String, dynamic> json) {
    // Handle social media links
    Map<String, String> socialLinks = {};
    if (json['social_media_links'] is Map) {
      final socialData = json['social_media_links'] as Map;
      socialData.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          socialLinks[key.toString()] = value.toString();
        }
      });
    }

    return ClientSpecificSettings(
      clientId: json['client_id']?.toString() ?? '',
      cafeRestaurantName: json['cafe_restaurant_name']?.toString() ?? 'اسم مقهى افتراضي',
      primaryColor: _parseColorFromJson(json['primary_color_hex']),
      googleSheetId: json['google_sheet_id']?.toString() ?? '',
      menuSheetName: json['menu_sheet_name']?.toString() ?? 'menu',
      categoriesSheetName: json['categories_sheet_name']?.toString() ?? 'categories',
      configSheetName: json['config_sheet_name']?.toString() ?? 'Client_Config',
      googleAppScriptUrl: json['google_app_script_url']?.toString() ?? json['base_api_url']?.toString(),
      contactEmail: json['contact_email']?.toString(),
      contactPhone: json['contact_phone']?.toString(),
      websiteUrl: json['website_url']?.toString(),
      socialMediaLinks: socialLinks.isNotEmpty ? socialLinks : null,
    );
  }

  static Color _parseColorFromJson(dynamic colorValue) {
    if (colorValue == null) return const Color(0xFF4CAF50);

    String colorHex = colorValue.toString();
    try {
      // Handle both #RRGGBB and #AARRGGBB formats
      colorHex = colorHex.replaceAll('#', '');
      if (colorHex.length == 6) {
        colorHex = 'FF$colorHex'; // Add alpha if missing
      }
      return Color(int.parse(colorHex, radix: 16));
    } catch (e) {
      return const Color(0xFF4CAF50); // Default green
    }
  }
}

/// Represents general application settings, typically from a local JSON file.
class AppSettings {
  final String appName;
  final String appVersion;
  final int buildNumber;
  final String defaultGoogleAppScriptUrl;
  final String companyName;
  final String privacyPolicyUrl;
  final String termsOfServiceUrl;
  final String appIconPath;
  final String splashScreenImagePath;
  final String defaultClientId;
  final String defaultGoogleSheetId;

  AppSettings({
    required this.appName,
    required this.appVersion,
    required this.buildNumber,
    required this.defaultGoogleAppScriptUrl,
    required this.companyName,
    required this.privacyPolicyUrl,
    required this.termsOfServiceUrl,
    required this.appIconPath,
    required this.splashScreenImagePath,
    required this.defaultClientId,
    required this.defaultGoogleSheetId,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      appName: json['app_name']?.toString() ?? 'قائمة الطعام الرقمية',
      appVersion: json['app_version']?.toString() ?? '1.0.0',
      buildNumber: json['build_number'] ?? 1,
      defaultGoogleAppScriptUrl: json['default_google_app_script_url']?.toString() ?? '',
      companyName: json['company_name']?.toString() ?? 'Your Dev Company',
      privacyPolicyUrl: json['privacy_policy_url']?.toString() ?? '',
      termsOfServiceUrl: json['terms_of_service_url']?.toString() ?? '',
      appIconPath: json['app_icon_path']?.toString() ?? 'assets/images/default_app_icon.png',
      splashScreenImagePath: json['splash_screen_image_path']?.toString() ?? 'assets/images/default_splash_logo.png',
      defaultClientId: json['default_client_id']?.toString() ?? 'DEFAULT_CLIENT_ID',
      defaultGoogleSheetId: json['default_google_sheet_id']?.toString() ?? '',
    );
  }
}

/// Represents application theming settings.
class ThemingSettings {
  final Color primaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color textColorLight;
  final Color textColorDark;

  ThemingSettings({
    required this.primaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.textColorLight,
    required this.textColorDark,
  });

  factory ThemingSettings.fromJson(Map<String, dynamic> json, Color primaryColorFromClient) {
    return ThemingSettings(
      primaryColor: primaryColorFromClient,
      accentColor: _parseColor(json['accent_color_hex'], const Color(0xFFFFC107)),
      backgroundColor: _parseColor(json['background_color_hex'], const Color(0xFFFFFFFF)),
      textColorLight: _parseColor(json['text_color_light_hex'], const Color(0xFF212121)),
      textColorDark: _parseColor(json['text_color_dark_hex'], const Color(0xFFFFFFFF)),
    );
  }

  static Color _parseColor(dynamic colorValue, Color fallback) {
    if (colorValue == null) return fallback;

    String colorHex = colorValue.toString();
    try {
      colorHex = colorHex.replaceAll('#', '').padLeft(8, 'FF');
      if (colorHex.length == 6) colorHex = 'FF$colorHex';
      return Color(int.parse(colorHex, radix: 16));
    } catch (e) {
      return fallback;
    }
  }
}

/// Singleton class to manage and provide application configurations.
class AppConfig {
  static final AppConfig instance = AppConfig._internal();
  factory AppConfig() => instance;
  AppConfig._internal();

  // Configuration objects
  late AppSettings appSettings;
  late ThemingSettings themingSettings;
  late ClientSpecificSettings clientSettings;

  // State management
  final Logger _logger = Logger();
  bool _isInitialized = false;
  bool _isLoading = false;

  // Default configuration constants
  static const String _DEFAULT_GOOGLE_SHEET_ID = '1FouCtLTDsf9cRLOXa0SkTq5yfPZAFhmUH-DhZGEMSQA';
  static const String _DEFAULT_APP_SCRIPT_URL = 'https://script.google.com/macros/s/AKfycbxFssAw90PDhLrIktF-2QhNa-NCfZN0yq67LiSwXJw/dev';
  static const String _DEFAULT_MENU_SHEET_NAME = 'menu';
  static const String _DEFAULT_CATEGORIES_SHEET_NAME = 'category';
  static const String _CONFIG_SHEET_NAME = 'Client_Config';
  static const String _DEFAULT_CAFE_NAME = 'اسم مقهى افتراضي';
  static const String _DEFAULT_CLIENT_ID = 'DEFAULT_CLIENT_ID';

  /// Main configuration loader - Entry point
  Future<void> loadConfig({String? initialClientId}) async {
    // Guard against multiple simultaneous calls
    if (_isInitialized) {
      _logger.w('Configuration already loaded');
      return;
    }

    if (_isLoading) {
      _logger.w('Configuration loading already in progress');
      return;
    }

    _isLoading = true;

    try {
      _logger.d('Starting configuration load process...');

      // Step 1: Load base app settings from local config
      await _loadAppSettings();

      // Step 2: Determine which client ID to use
      final clientIdToLoad = initialClientId ?? appSettings.defaultClientId;

      // Step 3: Try to load client-specific configuration
      if (clientIdToLoad.isNotEmpty && appSettings.defaultGoogleAppScriptUrl.isNotEmpty) {
        _logger.d('Attempting client-specific configuration load');
        await _loadClientSpecificConfiguration(clientIdToLoad);
      } else {
        if (clientIdToLoad.isEmpty) {
          _logger.w('No client ID available (empty or null)');
        }
        if (appSettings.defaultGoogleAppScriptUrl.isEmpty) {
          _logger.w('No Google App Script URL configured');
        }
        _logger.w('Using default configuration only');
        await _loadDefaultClientConfiguration();
      }

      // Step 4: Load theming settings
      await _loadThemingSettings();

      _isInitialized = true;
      _logger.i('Configuration loaded successfully');

    } catch (e, stackTrace) {
      _logger.e('Fatal error loading configuration', error: e, stackTrace: stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  /// Load base application settings from local JSON file
  Future<void> _loadAppSettings() async {
    try {
      final configJsonString = await rootBundle.loadString(BASE_CONFIG_FILE);
      final configJson = json.decode(configJsonString);
      appSettings = AppSettings.fromJson(configJson['app_settings'] ?? {});

      _logger.d('Base app settings loaded:');
      _logger.d('  App Name: ${appSettings.appName}');
      _logger.d('  Default Client ID: ${appSettings.defaultClientId}');
      _logger.d('  Default Google Sheet ID: ${appSettings.defaultGoogleSheetId}');
      _logger.d('  App Script URL: ${appSettings.defaultGoogleAppScriptUrl.isEmpty ? "NOT SET" : "SET"}');

      // Validate critical settings
      if (appSettings.defaultGoogleAppScriptUrl.isEmpty) {
        _logger.w('WARNING: default_google_app_script_url is empty in config file');
      }

    } catch (e) {
      _logger.e('Failed to load app settings: $e');
      rethrow;
    }
  }

  /// Load client-specific configuration from Google Sheets
  Future<void> _loadClientSpecificConfiguration(String clientId) async {
    try {
      _logger.d('Attempting to load client-specific config for: $clientId');

      // Validate that we have the necessary URLs
      if (appSettings.defaultGoogleAppScriptUrl.isEmpty) {
        throw Exception('Google App Script URL is not configured in app settings');
      }

      _logger.d('Using App Script URL: ${appSettings.defaultGoogleAppScriptUrl}');
      await _fetchClientConfigFromAPI(clientId, appSettings.defaultGoogleAppScriptUrl);
      _logger.i('Client-specific configuration loaded successfully');
    } catch (e) {
      _logger.e('Client config failed, falling back to defaults: $e');
      await _loadDefaultClientConfiguration();
    }
  }

  /// Fetch client configuration from Google Apps Script API
  Future<void> _fetchClientConfigFromAPI(String clientId, String appScriptUrl) async {
    final uri = Uri.parse(appScriptUrl).replace(queryParameters: {
      'action': 'getClientConfig',
      'client_id': clientId,
    });

    _logger.d('Fetching client config from: ${uri.toString()}');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      _logger.d('API Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        _logger.d('Raw config data: $data');

        // Validate that we got actual config data
        if (data.isEmpty || !data.containsKey('client_id')) {
          throw FormatException('Invalid or empty client configuration received');
        }

        clientSettings = ClientSpecificSettings.fromJson(data);
        _logger.i('Client settings created successfully');

      } else if (response.statusCode >= 400) {
        final errorData = json.decode(response.body);
        final errorMsg = errorData['error'] ?? 'Unknown server error';
        throw HttpException('HTTP ${response.statusCode}: $errorMsg');
      } else {
        throw HttpException('Unexpected HTTP status: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      throw Exception('Network unavailable: ${e.message}');
    } on TimeoutException {
      throw Exception('Request timed out - server may be busy');
    } on FormatException catch (e) {
      throw Exception('Invalid JSON response: ${e.message}');
    } on HttpException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to fetch client config: $e');
    }
  }

  /// Load default client configuration from local settings
  Future<void> _loadDefaultClientConfiguration() async {
    try {
      _logger.d('Loading default client configuration');

      final configJsonString = await rootBundle.loadString(BASE_CONFIG_FILE);
      final configJson = json.decode(configJsonString);

      // Try to get client settings from 'client_settings' section first, then fallback to app_settings
      final clientSettingsSection = configJson['client_settings'] ?? {};
      final themingSection = configJson['theming_settings'] ?? {};

      clientSettings = ClientSpecificSettings(
        clientId: _getStringValue(clientSettingsSection, 'client_id', appSettings.defaultClientId),
        cafeRestaurantName: _getStringValue(clientSettingsSection, 'cafe_restaurant_name', appSettings.appName),
        primaryColor: _parseColor(themingSection['primary_color_hex'], const Color(0xFF4CAF50)),
        googleSheetId: _getStringValue(clientSettingsSection, 'google_sheet_id', appSettings.defaultGoogleSheetId),
        menuSheetName: _getStringValue(clientSettingsSection, 'menu_sheet_name', _DEFAULT_MENU_SHEET_NAME),
        categoriesSheetName: _getStringValue(clientSettingsSection, 'categories_sheet_name', _DEFAULT_CATEGORIES_SHEET_NAME),
        configSheetName: _getStringValue(clientSettingsSection, 'config_sheet_name', _CONFIG_SHEET_NAME),
        googleAppScriptUrl: _getStringValue(clientSettingsSection, 'base_api_url', appSettings.defaultGoogleAppScriptUrl),
      );

      _logger.d('Default client configuration loaded:');
      _logger.d('  Client ID: ${clientSettings.clientId}');
      _logger.d('  Cafe Name: ${clientSettings.cafeRestaurantName}');
      _logger.d('  Google Sheet ID: ${clientSettings.googleSheetId}');
      _logger.d('  API URL: ${clientSettings.googleAppScriptUrl}');

    } catch (e) {
      _logger.e('Failed to load default client config: $e');
      rethrow;
    }
  }

  /// Load theming settings using client's primary color
  Future<void> _loadThemingSettings() async {
    try {
      final configJsonString = await rootBundle.loadString(BASE_CONFIG_FILE);
      final configJson = json.decode(configJsonString);

      themingSettings = ThemingSettings.fromJson(
        configJson['theming_settings'] ?? {},
        clientSettings.primaryColor,
      );

      _logger.d('Theming settings loaded with primary color: ${clientSettings.primaryColor}');
    } catch (e) {
      _logger.e('Failed to load theming settings: $e');
      rethrow;
    }
  }

  /// Helper method to safely get string values from config
  String _getStringValue(Map<String, dynamic> config, String key, String defaultValue) {
    final value = config[key]?.toString()?.trim();
    return (value?.isNotEmpty == true) ? value! : defaultValue;
  }

  /// Helper method to parse color strings safely
  Color _parseColor(dynamic colorValue, Color fallback) {
    if (colorValue == null) return fallback;

    String colorHex = colorValue.toString();
    try {
      colorHex = colorHex.replaceAll('#', '').padLeft(8, 'FF');
      if (colorHex.length == 6) colorHex = 'FF$colorHex';
      return Color(int.parse(colorHex, radix: 16));
    } catch (e) {
      _logger.w('Invalid color format: "$colorValue". Using fallback.');
      return fallback;
    }
  }

  /// Force reload configuration (useful for testing/debugging)
  Future<void> reloadConfig({String? clientId}) async {
    _logger.i('Force reloading configuration...');
    _isInitialized = false;
    _isLoading = false;
    await loadConfig(initialClientId: clientId);
  }

  /// Check if configuration is loaded and ready
  bool get isInitialized => _isInitialized;

  /// Check if currently loading
  bool get isLoading => _isLoading;

  /// Get current configuration summary for debugging
  Map<String, dynamic> getConfigSummary() {
    if (!_isInitialized) return {'status': 'not_initialized'};

    return {
      'status': 'initialized',
      'client_id': clientSettings.clientId,
      'cafe_name': clientSettings.cafeRestaurantName,
      'google_sheet_id': clientSettings.googleSheetId,
      'menu_sheet_name': clientSettings.menuSheetName,
      'categories_sheet_name': clientSettings.categoriesSheetName,
      'primary_color': '#${clientSettings.primaryColor.value.toRadixString(16).padLeft(8, '0')}',
    };
  }

  /// Debug method to check configuration file contents
  Future<Map<String, dynamic>> debugConfigFile() async {
    try {
      final configJsonString = await rootBundle.loadString(BASE_CONFIG_FILE);
      final configJson = json.decode(configJsonString);

      return {
        'file_loaded': true,
        'has_app_settings': configJson.containsKey('app_settings'),
        'has_client_settings': configJson.containsKey('client_settings'),
        'has_theming_settings': configJson.containsKey('theming_settings'),
        'app_settings_keys': configJson['app_settings']?.keys?.toList() ?? [],
        'client_settings_keys': configJson['client_settings']?.keys?.toList() ?? [],
        'default_google_app_script_url_present':
        configJson['app_settings']?['default_google_app_script_url']?.toString().isNotEmpty ?? false,
        'default_google_app_script_url_value':
        configJson['app_settings']?['default_google_app_script_url']?.toString() ?? 'NOT SET',
        'base_api_url_value':
        configJson['client_settings']?['base_api_url']?.toString() ?? 'NOT SET',
        'default_client_id':
        configJson['app_settings']?['default_client_id']?.toString() ?? 'NOT SET',
        'client_id_in_client_settings':
        configJson['client_settings']?['client_id']?.toString() ?? 'NOT SET',
      };
    } catch (e) {
      return {
        'file_loaded': false,
        'error': e.toString(),
      };
    }
  }

  /// Test method to validate configuration step by step
  Future<Map<String, dynamic>> testConfiguration() async {
    final results = <String, dynamic>{};

    try {
      // Test 1: Load base config file
      results['step1_file_load'] = 'attempting';
      final configJsonString = await rootBundle.loadString(BASE_CONFIG_FILE);
      final configJson = json.decode(configJsonString);
      results['step1_file_load'] = 'success';

      // Test 2: Parse app settings
      results['step2_app_settings'] = 'attempting';
      final testAppSettings = AppSettings.fromJson(configJson['app_settings'] ?? {});
      results['step2_app_settings'] = 'success';
      results['app_script_url'] = testAppSettings.defaultGoogleAppScriptUrl;
      results['app_script_url_empty'] = testAppSettings.defaultGoogleAppScriptUrl.isEmpty;

      // Test 3: Parse client settings
      results['step3_client_settings'] = 'attempting';
      final clientSettingsSection = configJson['client_settings'] ?? {};
      final themingSection = configJson['theming_settings'] ?? {};

      final testClientSettings = ClientSpecificSettings(
        clientId: _getStringValue(clientSettingsSection, 'client_id', testAppSettings.defaultClientId),
        cafeRestaurantName: _getStringValue(clientSettingsSection, 'cafe_restaurant_name', testAppSettings.appName),
        primaryColor: _parseColor(themingSection['primary_color_hex'], const Color(0xFF4CAF50)),
        googleSheetId: _getStringValue(clientSettingsSection, 'google_sheet_id', testAppSettings.defaultGoogleSheetId),
        menuSheetName: _getStringValue(clientSettingsSection, 'menu_sheet_name', _DEFAULT_MENU_SHEET_NAME),
        categoriesSheetName: _getStringValue(clientSettingsSection, 'categories_sheet_name', _DEFAULT_CATEGORIES_SHEET_NAME),
        configSheetName: _getStringValue(clientSettingsSection, 'config_sheet_name', _CONFIG_SHEET_NAME),
        googleAppScriptUrl: _getStringValue(clientSettingsSection, 'base_api_url', testAppSettings.defaultGoogleAppScriptUrl),
      );
      results['step3_client_settings'] = 'success';
      results['final_app_script_url'] = testClientSettings.googleAppScriptUrl;

      // Test 4: Parse theming
      results['step4_theming'] = 'attempting';
      final testTheming = ThemingSettings.fromJson(
        themingSection,
        testClientSettings.primaryColor,
      );
      results['step4_theming'] = 'success';

      results['overall_status'] = 'success';

    } catch (e, stackTrace) {
      results['error'] = e.toString();
      results['stack_trace'] = stackTrace.toString();
      results['overall_status'] = 'failed';
    }

    return results;
  }
}