import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_2/utils/localization/app_translations.dart';
import 'package:flutter_application_2/utils/widgets/custom_app_bar.dart';
import 'package:iconsax/iconsax.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'settings',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // General Settings Section
              _buildSectionTitle(context, 'general'.tr),
              const SizedBox(height: 8),
              
              // Language Setting
              _buildSettingTile(
                context,
                icon: Iconsax.language_square,
                title: 'language'.tr,
                subtitle: AppTranslations.getCurrentLanguageName(),
                onTap: () => _showLanguageDialog(context),
              ),
              
              const Divider(),
              
              // Theme Setting
              _buildSettingTile(
                context,
                icon: Iconsax.moon,
                title: 'theme'.tr,
                subtitle: Get.isDarkMode ? 'dark_mode'.tr : 'light_mode'.tr,
                onTap: () {
                  // Toggle theme
                  Get.changeThemeMode(
                    Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              // Account Settings Section
              _buildSectionTitle(context, 'account'.tr),
              const SizedBox(height: 8),
              
              // Profile Setting
              _buildSettingTile(
                context,
                icon: Iconsax.user,
                title: 'profile'.tr,
                onTap: () {
                  // Navigate to profile screen
                },
              ),
              
              const Divider(),
              
              // Notifications Setting
              _buildSettingTile(
                context,
                icon: Iconsax.notification,
                title: 'notifications'.tr,
                onTap: () {
                  // Navigate to notifications settings
                },
              ),
              
              const SizedBox(height: 20),
              
              // About Section
              _buildSectionTitle(context, 'about'.tr),
              const SizedBox(height: 8),
              
              // Help Setting
              _buildSettingTile(
                context,
                icon: Iconsax.info_circle,
                title: 'help'.tr,
                onTap: () {
                  // Navigate to help screen
                },
              ),
              
              const Divider(),
              
              // Localization Demo
              _buildSettingTile(
                context,
                icon: Iconsax.translate,
                title: 'localization_demo'.tr,
                onTap: () {
                  // Navigate to localization demo screen
                  Get.toNamed('/localization-demo');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build section titles
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  // Helper method to build setting tiles
  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
  
  // Show language selection dialog
  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('select_language'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // English option
            _buildLanguageOption(
              context,
              name: 'English',
              code: 'en',
              country: 'US',
            ),
            const SizedBox(height: 10),
            
            // Amharic option
            _buildLanguageOption(
              context,
              name: 'አማርኛ',
              code: 'am',
              country: 'ET',
            ),
            const SizedBox(height: 10),
            
            // Oromo option
            _buildLanguageOption(
              context,
              name: 'Afaan Oromoo',
              code: 'om',
              country: 'ET',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('close'.tr),
          ),
        ],
      ),
    );
  }
  
  // Build a language option button
  Widget _buildLanguageOption(
    BuildContext context, {
    required String name,
    required String code,
    required String country,
  }) {
    final isSelected = AppTranslations.savedLanguageCode == '${code}_$country';
    
    return InkWell(
      onTap: () {
        AppTranslations.changeLanguage(code, country);
        Navigator.of(context).pop();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
              ),
          ],
        ),
      ),
    );
  }
}
