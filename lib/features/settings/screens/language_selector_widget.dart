import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_2/utils/localization/app_translations.dart';

class LanguageSelectorWidget extends StatelessWidget {
  const LanguageSelectorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.language,
            size: 70,
            color: Colors.blue,
          ),
          const SizedBox(height: 20),
          Text(
            'select_language'.tr,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          
          // English language option
          _buildLanguageOption(
            name: 'English',
            code: 'en',
            country: 'US',
          ),
          
          const SizedBox(height: 10),
          
          // Amharic language option
          _buildLanguageOption(
            name: 'አማርኛ', // Amharic
            code: 'am',
            country: 'ET',
          ),
          
          const SizedBox(height: 10),
          
          // Oromo language option
          _buildLanguageOption(
            name: 'Afaan Oromoo', // Oromo
            code: 'om',
            country: 'ET',
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required String name,
    required String code,
    required String country,
  }) {
    final isSelected = AppTranslations.savedLanguageCode == '${code}_$country';
    
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey.shade200,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        minimumSize: const Size(200, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: () {
        AppTranslations.changeLanguage(code, country);
      },
      child: Text(name),
    );
  }
}
