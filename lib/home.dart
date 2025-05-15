import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/features/ticket/screen/bottomNavigationBar.dart';
import 'package:flutter_application_2/utils/constants/sizes.dart';
import 'package:flutter_application_2/utils/helpers/helper_functions.dart';
import 'package:flutter_application_2/utils/localization/app_translations.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    final size = MediaQuery.of(context).size;
    
    // Apply dark mode specific styling if needed
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    
    // Set system overlay style for better immersion
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        children: [
          // Background image with parallax effect
          Container(
            height: size.height,
            width: size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage(
                  'assets/images/banners/00361362_9d16cff119a5c96118bc8e3458c80b9a_arc614x376_w735_us1.jpg',
                ),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.4),
                  BlendMode.darken,
                ),
                alignment: Alignment(0, -0.3),
              ),
            ),
          ),
          
          // Gradient overlay for better text readability
          Container(
            height: size.height,
            width: size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.7),
                ],
                stops: const [0.1, 0.6, 1.0],
              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar with language selector and profile
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TSizes.defaultSpace,
                    vertical: TSizes.sm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Language selector with enhanced design
                      _buildLanguageSelectionRow(),
                      
                      // Profile icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Iconsax.user,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Main content area
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: TSizes.defaultSpace,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // App branding
                          const SizedBox(height: TSizes.spaceBtwSections),
                          Row(
                            children: [
                              Icon(
                                Iconsax.bus,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: TSizes.xs),
                              Text(
                                'app_name'.tr,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          
                          // Hero section
                          const SizedBox(height: TSizes.spaceBtwSections),
                          Text(
                            'book_ticket'.tr,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: TSizes.sm),
                          Text(
                            'easy_booking_subtitle'.tr,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8),
                              height: 1.5,
                            ),
                          ),
                          
                          // Schedule card with enhanced design
                          const SizedBox(height: TSizes.spaceBtwSections),
                          _buildTrainScheduleCard(),
                          
                          // Removed popular destinations section
                          
                          // Book now button with enhanced design
                          const SizedBox(height: TSizes.spaceBtwSections),
                          _buildBookNowButton(),
                          const SizedBox(height: TSizes.spaceBtwSections),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Language selector row that's directly integrated in the UI
  Widget _buildLanguageSelectionRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.global, color: Colors.white, size: 16),
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

  // Train schedule card with enhanced design
  Widget _buildTrainScheduleCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade900.withOpacity(0.7),
            Colors.indigo.shade800.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Iconsax.bus,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'train_schedule'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildScheduleItem(
            'Addis Ababa → Dire Dawa',
            'Odd-numbered days',
            Iconsax.arrow_right_3,
          ),
          Divider(color: Colors.white.withOpacity(0.2), height: 20),
          _buildScheduleItem(
            'Dire Dawa → Addis Ababa',
            'Even-numbered days',
            Iconsax.arrow_left_2,
          ),
          Divider(color: Colors.white.withOpacity(0.2), height: 20),
          Row(
            children: [
              Icon(
                Iconsax.info_circle,
                color: Colors.amber,
                size: 16,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'No service on 29th & 31st of any month',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 13,
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

  // Book now button with enhanced design
  Widget _buildBookNowButton() {
    return GestureDetector(
      onTap: () {
        showCitizenshipBottomSheet();
      },
      child: Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade600,
              Colors.blue.shade800,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade900.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'book_ticket'.tr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: TSizes.sm),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.bus,
                color: Colors.white,
                size: 18,
              ),
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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 0,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.user_octagon,
                  color: Colors.blue.shade700,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'select_citizenship'.tr,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildCitizenshipOption('ethiopian_citizen'.tr, 'Ethiopian', Colors.green),
            const SizedBox(height: 12),
            _buildCitizenshipOption('djibouti_citizen'.tr, 'Djiboutian', Colors.blue),
            const SizedBox(height: 12),
            _buildCitizenshipOption('foreign_citizen'.tr, 'Foreign', Colors.orange),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // Citizenship option with enhanced design
  Widget _buildCitizenshipOption(String title, String citizenshipType, MaterialColor baseColor) {
    return GestureDetector(
      onTap: () => Get.to(() => CustomBottomNavigationBar(
        selectedCitizenship: citizenshipType,
      )),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              baseColor.shade600,
              baseColor.shade900,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: baseColor.shade900.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                citizenshipType == 'Ethiopian' ? Iconsax.flag : 
                citizenshipType == 'Djiboutian' ? Iconsax.flag : Iconsax.global,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    citizenshipType == 'Ethiopian' ? 'For Ethiopian citizens with Fayda ID' :
                    citizenshipType == 'Djiboutian' ? 'For Djibouti citizens with passport' :
                    'For foreigners with passport',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Iconsax.arrow_right_3,
              color: Colors.white.withOpacity(0.7),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
  
  // Removed the unused _buildDestinationCard method
  
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
