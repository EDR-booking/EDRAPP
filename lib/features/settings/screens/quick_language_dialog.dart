import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_2/utils/localization/app_translations.dart';

class QuickLanguageDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'select_language'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              _buildLanguageButton('English', 'en', 'US'),
              const SizedBox(height: 10),
              _buildLanguageButton('አማርኛ', 'am', 'ET'),
              const SizedBox(height: 10),
              _buildLanguageButton('Afaan Oromoo', 'om', 'ET'),
              
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('close'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildLanguageButton(String name, String langCode, String countryCode) {
    final isSelected = AppTranslations.savedLanguageCode == '${langCode}_$countryCode';
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue : null,
          foregroundColor: isSelected ? Colors.white : null,
        ),
        onPressed: () {
          AppTranslations.changeLanguage(langCode, countryCode);
          Get.back(); // Close dialog
        },
        child: Text(name),
      ),
    );
  }
}
