import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/ticket/screen/bottomNavigationBar.dart';
import 'package:flutter_application_2/utils/localization/app_translations.dart';
import 'package:get/get.dart';
import 'package:flutter_application_2/utils/constants/sizes.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No app bar for cleaner fullscreen experience
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/banners/00361362_9d16cff119a5c96118bc8e3458c80b9a_arc614x376_w735_us1.jpg',
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.darken,
            ),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color.fromARGB(255, 170, 217, 255).withOpacity(0.2),
                Colors.indigo.withOpacity(0.6),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Language selector at the top - directly integrated in main UI
              _buildLanguageSelectionRow(),
              
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: TSizes.defaultSpace,
                  vertical: 30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'app_name'.tr,
                      style: const TextStyle(
                        fontSize: TSizes.md,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(1.0, 1.0),
                            blurRadius: 3.0,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'book_ticket'.tr,
                      style: const TextStyle(
                        fontSize: TSizes.lg,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(1.0, 1.0),
                            blurRadius: 3.0,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTrainScheduleCard(),
                    const SizedBox(height: 20),
                    _buildBookNowButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Language selector row that's directly integrated in the UI
  Widget _buildLanguageSelectionRow() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.language, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          _buildLanguageButton('🇺🇸 EN', 'en', 'US'),
          const SizedBox(width: 5),
          _buildLanguageButton('🇪🇹 አማ', 'am', 'ET'),
          const SizedBox(width: 5),
          _buildLanguageButton('🇪🇹 OR', 'om', 'ET'),
        ],
      ),
    );
  }

  // Train schedule card
  Widget _buildTrainScheduleCard() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.4),
            Colors.indigo.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.train_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 10),
              Text(
                'train_schedule'.tr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: TSizes.md,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          _buildScheduleItem(
            'Addis Ababa → Dire Dawa',
            'Odd-numbered days',
            Icons.east_rounded,
          ),
          Divider(color: Colors.white.withOpacity(0.2), height: 20),
          _buildScheduleItem(
            'Dire Dawa → Addis Ababa',
            'Even-numbered days',
            Icons.west_rounded,
          ),
          Divider(color: Colors.white.withOpacity(0.2), height: 20),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.amber,
                size: 16,
              ),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'No service on 29th & 31st of any month',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Book now button
  Widget _buildBookNowButton() {
    return InkWell(
      onTap: () {
        showCitizenshipBottomSheet();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue,
              Colors.blue.shade800,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'book_ticket'.tr,
              style: TextStyle(
                color: Colors.white,
                fontSize: TSizes.lg,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(width: TSizes.sm),
            Icon(
              Icons.train_rounded,
              color: Colors.white,
              size: TSizes.lg,
            ),
          ],
        ),
      ),
    );
  }

  // Function to Show Bottom Sheet
  Widget _buildLanguageButton(String label, String langCode, String countryCode) {
    // Use AppTranslations to check if this is the current language
    bool isSelected = AppTranslations.savedLanguageCode == '${langCode}_$countryCode';
    
    return InkWell(
      onTap: () {
        // Change language using our AppTranslations class
        AppTranslations.changeLanguage(langCode, countryCode);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void showCitizenshipBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Your Citizenship',
              style: TextStyle(
                fontSize: TSizes.lg,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Are you Ethiopian or a foreigner?',
              style: TextStyle(fontSize: TSizes.md, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Text(
              'For Ethiopians, a Fayda ID is required. For Djiboutians and other foreigners, a passport ID is required',
              style: TextStyle(fontSize: TSizes.md, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            // Ethiopian Citizen Button
            _citizenshipButton(
              title: "Ethiopian Citizen",
              icon: Icons.flag,
              color: const Color.fromARGB(255, 24, 63, 26),
              onTap: () => Get.to(() => CustomBottomNavigationBar(selectedCitizenship: 'Ethiopian')),
            ),

            // Djibouti Citizen Button
            _citizenshipButton(
              title: "Djibouti Citizen",
              icon: Icons.language,
              color: const Color.fromARGB(255, 30, 75, 153),
              onTap: () => Get.to(() => CustomBottomNavigationBar(selectedCitizenship: 'Djiboutian')),
            ),

            // Foreign Citizen Button
            _citizenshipButton(
              title: "Foreign Citizen",
              icon: Icons.public,
              color: const Color.fromARGB(210, 255, 158, 11),
              onTap: () => Get.to(() => CustomBottomNavigationBar(selectedCitizenship: 'Foreign')),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // Reusable Citizenship Button
  Widget _citizenshipButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
  
  // Schedule item widget
  Widget _buildScheduleItem(String route, String days, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
        ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              route,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              days,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
