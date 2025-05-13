import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_2/utils/localization/app_translations.dart';
import 'package:flutter_application_2/utils/widgets/custom_app_bar.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'language',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'select_language'.tr,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: AppTranslations.languages.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final language = AppTranslations.languages[index];
                  final isSelected = 
                      AppTranslations.savedLanguageCode == language['code'];
                  
                  return ListTile(
                    title: Text(
                      language['name'],
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected 
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () {
                      final locale = language['locale'] as Locale;
                      AppTranslations.changeLanguage(
                        locale.languageCode,
                        locale.countryCode!,
                      );
                      Get.back(); // Return to previous screen
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
