// Model class for AppSettings
import 'dart:convert';
import 'dart:developer' as Get show log;

import 'package:flutter/services.dart';

class AppSettings {
  final String appName;
  final String appVersion;
  final int buildNumber;
  final String companyName;
  final String privacyPolicyUrl;
  final String termsOfServiceUrl;
  final String appIconPath;
  final String splashScreenImagePath;

  AppSettings({
    required this.appName,
    required this.appVersion,
    required this.buildNumber,
    required this.companyName,
    required this.privacyPolicyUrl,
    required this.termsOfServiceUrl,
    required this.appIconPath,
    required this.splashScreenImagePath,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      appName: json['app_name'] ?? 'Unknown App',
      appVersion: json['app_version'] ?? '0.0.0',
      buildNumber: json['build_number'] ?? 0,
      companyName: json['company_name'] ?? 'Unknown Company',
      privacyPolicyUrl: json['privacy_policy_url'] ?? '',
      termsOfServiceUrl: json['terms_of_service_url'] ?? '',
      appIconPath: json['app_icon_path'] ?? '',
      splashScreenImagePath: json['splash_screen_image_path'] ?? '',
    );
  }
}

// Model class for ClientSettings
class ClientSettings {
  final String clientId;

  // Renamed to camelCase for Dart convention, but keep original for JSON key
  final String baseApiUrl;
  final String cafeRestaurantName;
  final String googleSheetId;
  final String menuSheetName;
  final String categoriesSheetName;
  final String configSheetName;
  final String contactEmail;
  final String contactPhone;
  final String websiteUrl;
  final Map<String, dynamic> socialMediaLinks;

  ClientSettings({
    required this.clientId,
    required this.cafeRestaurantName,
    required this.googleSheetId,
    required this.menuSheetName,
    required this.categoriesSheetName,
    required this.configSheetName,
    required this.contactEmail,
    required this.contactPhone,
    required this.websiteUrl,
    required this.socialMediaLinks,
    required this.baseApiUrl, // Corrected parameter name
  });

  factory ClientSettings.fromJson(Map<String, dynamic> json) {
    return ClientSettings(
      clientId: json['client_id'] ?? 'DEFAULT_CLIENT_ID',
      // Corrected key name in JSON access and fallback value
      baseApiUrl: json['base_api_url'] ?? '',
      cafeRestaurantName: json['cafe_restaurant_name'] ?? 'Default Cafe',
      googleSheetId: json['google_sheet_id'] ?? '',
      menuSheetName: json['menu_sheet_name'] ?? 'Menu_Items',
      categoriesSheetName: json['categories_sheet_name'] ?? 'Categories',
      configSheetName: json['config_sheet_name'] ?? 'Client_Config',
      contactEmail: json['contact_email'] ?? '',
      contactPhone: json['contact_phone'] ?? '',
      websiteUrl: json['website_url'] ?? '',
      socialMediaLinks: json['social_media_links'] ?? {},
    );
  }
}

// Model class for Theming
class ThemingSettings {
  final String primaryColorHex;
  final String accentColorHex;
  final String backgroundColorHex;
  final String textColorLightHex;
  final String textColorDarkHex;
  final String fontFamily;
  final bool darkModeEnabled;

  ThemingSettings({
    required this.primaryColorHex,
    required this.accentColorHex,
    required this.backgroundColorHex,
    required this.textColorLightHex,
    required this.textColorDarkHex,
    required this.fontFamily,
    required this.darkModeEnabled,
  });

  factory ThemingSettings.fromJson(Map<String, dynamic> json) {
    return ThemingSettings(
      primaryColorHex: json['primary_color_hex'] ?? '#FF000000',
      accentColorHex: json['accent_color_hex'] ?? '#FF000000',
      backgroundColorHex: json['background_color_hex'] ?? '#FFFFFFFF',
      textColorLightHex: json['text_color_light_hex'] ?? '#FF000000',
      textColorDarkHex: json['text_color_dark_hex'] ?? '#FFFFFFFF',
      fontFamily: json['font_family'] ?? 'Roboto',
      darkModeEnabled: json['dark_mode_enabled'] ?? false,
    );
  }

  Color get primaryColor => Color(int.parse(primaryColorHex.replaceAll('#', '0xFF')));

  Color get accentColor => Color(int.parse(accentColorHex.replaceAll('#', '0xFF')));

  Color get backgroundColor => Color(int.parse(backgroundColorHex.replaceAll('#', '0xFF')));

  Color get textColorLight => Color(int.parse(textColorLightHex.replaceAll('#', '0xFF')));

  Color get textColorDark => Color(int.parse(textColorDarkHex.replaceAll('#', '0xFF')));

  // يمكن إضافة المزيد من getter لـ ThemeData لاحقاً
}

// Model class for QrCodeSettings
class QrCodeSettings {
  final String baseQrUrl;
  final double qrSize;
  final String qrForegroundColorHex;
  final String qrBackgroundColorHex;

  QrCodeSettings({required this.baseQrUrl, required this.qrSize, required this.qrForegroundColorHex, required this.qrBackgroundColorHex});

  factory QrCodeSettings.fromJson(Map<String, dynamic> json) {
    return QrCodeSettings(
      baseQrUrl: json['base_qr_url'] ?? '',
      qrSize: (json['qr_size'] as num?)?.toDouble() ?? 200.0,
      qrForegroundColorHex: json['qr_foreground_color_hex'] ?? '#FF000000',
      qrBackgroundColorHex: json['qr_background_color_hex'] ?? '#FFFFFFFF',
    );
  }
}

// Main App Configuration class
class AppConfig {
  late AppSettings appSettings;
  late ClientSettings clientSettings;
  late ThemingSettings themingSettings;
  late QrCodeSettings qrCodeSettings;

  static AppConfig? _instance; // Singleton instance

  AppConfig._internal(); // Private constructor

  static AppConfig get instance {
    _instance ??= AppConfig._internal();
    return _instance!;
  }

  Future<void> loadConfig() async {
    try {
      final String response = await rootBundle.loadString('assets/data/app_config.json');
      final data = json.decode(response);

      appSettings = AppSettings.fromJson(data['app_settings']);
      clientSettings = ClientSettings.fromJson(data['client_settings']);
      themingSettings = ThemingSettings.fromJson(data['theming']);
      qrCodeSettings = QrCodeSettings.fromJson(data['qr_code_settings']);

      Get.log('Config loaded successfully!');
      Get.log('App Name: ${appSettings.appName}');
      Get.log('Cafe Name: ${clientSettings.cafeRestaurantName}');
      Get.log('Primary Color: ${themingSettings.primaryColorHex}');
      Get.log('Base API URL: ${clientSettings.baseApiUrl}'); // Log the API URL too
    } catch (e) {
      Get.log('Error loading app config: $e');
      // يمكنك هنا تعيين قيم افتراضية أو عرض شاشة خطأ
      appSettings = AppSettings(
        appName: 'Error App',
        appVersion: '0.0.0',
        buildNumber: 0,
        companyName: 'Error Co.',
        privacyPolicyUrl: '',
        termsOfServiceUrl: '',
        appIconPath: '',
        splashScreenImagePath: '',
      );
      clientSettings = ClientSettings(
        clientId: 'ERROR',
        cafeRestaurantName: 'Error Cafe',
        googleSheetId: '',
        menuSheetName: '',
        baseApiUrl: '',
        // Corrected parameter name
        categoriesSheetName: '',
        configSheetName: '',
        contactEmail: '',
        contactPhone: '',
        websiteUrl: '',
        socialMediaLinks: {},
      );
      themingSettings = ThemingSettings(
        primaryColorHex: '#FF000000',
        accentColorHex: '#FF000000',
        backgroundColorHex: '#FFFFFFFF',
        textColorLightHex: '#FF000000',
        textColorDarkHex: '#FFFFFFFF',
        fontFamily: 'Roboto',
        darkModeEnabled: false,
      );
      qrCodeSettings = QrCodeSettings(baseQrUrl: '', qrSize: 0.0, qrForegroundColorHex: '', qrBackgroundColorHex: '');
    }
  }
}
