import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_application_2/utils/localization/translations/en_US.dart';
import 'package:flutter_application_2/utils/localization/translations/am_ET.dart';
import 'package:flutter_application_2/utils/localization/translations/om_ET.dart';

class AppTranslations extends Translations {
  // Default locale
  static final Locale locale = Locale('en', 'US');
  
  // Fallback locale
  static final Locale fallbackLocale = Locale('en', 'US');
  
  // Supported locales
  static final List<Locale> supportedLocales = [
    Locale('en', 'US'), // English
    Locale('am', 'ET'), // Amharic
    Locale('om', 'ET'), // Oromo
  ];
  
  // Supported languages info for UI display
  static final List<Map<String, dynamic>> languages = [
    {
      'name': 'English',
      'locale': Locale('en', 'US'),
      'code': 'en_US',
    },
    {
      'name': 'አማርኛ',  // Amharic
      'locale': Locale('am', 'ET'),
      'code': 'am_ET',
    },
    {
      'name': 'Afaan Oromoo',  // Oromo
      'locale': Locale('om', 'ET'),
      'code': 'om_ET',
    },
  ];

  // Store the selected language code
  static final _box = GetStorage();
  static const _key = 'selectedLanguage';
  
  // Get saved language code from storage
  static String get savedLanguageCode => _box.read<String>(_key) ?? 'en_US';
  
  // Save language code to storage
  static saveLanguageCode(String languageCode) => _box.write(_key, languageCode);
  
  // Get current locale
  static Locale getCurrentLocale() {
    String storedLanguageCode = savedLanguageCode;
    
    // Find the locale for the stored language code
    for (var language in languages) {
      if (language['code'] == storedLanguageCode) {
        return language['locale'];
      }
    }
    
    // Default to English if not found
    return locale;
  }
  
  // Get the name of the current language
  static String getCurrentLanguageName() {
    String storedLanguageCode = savedLanguageCode;
    
    // Find the name for the stored language code
    for (var language in languages) {
      if (language['code'] == storedLanguageCode) {
        return language['name'];
      }
    }
    
    // Default to English if not found
    return 'English';
  }
  
  // Change language
  static void changeLanguage(String languageCode, String countryCode) {
    final locale = Locale(languageCode, countryCode);
    saveLanguageCode('${languageCode}_$countryCode');
    Get.updateLocale(locale);
  }
  
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': enUS,
    'am_ET': amET,
    'om_ET': omET,
  };
}
