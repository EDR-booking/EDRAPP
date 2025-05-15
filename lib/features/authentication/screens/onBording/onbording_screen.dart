import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/features/authentication/controllers/onboarding/onbording_controlller.dart';
import 'package:flutter_application_2/utils/constants/colors.dart';
import 'package:flutter_application_2/utils/constants/image_strings.dart';
import 'package:flutter_application_2/utils/constants/sizes.dart';
import 'package:flutter_application_2/utils/constants/text_strings.dart';
import 'package:flutter_application_2/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnbordingScreen extends StatelessWidget {
  const OnbordingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OnbordingControlller controller = Get.put(OnbordingControlller());
    final isDark = THelperFunctions.isDarkMode(context);
    final screenSize = MediaQuery.of(context).size;
    
    // Set system overlay style based on theme
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark 
                  ? [Colors.black, Colors.blueGrey.shade900] 
                  : [Colors.white, Colors.blue.shade50],
              ),
            ),
          ),
          
          // Page View with enhanced animation
          Obx(() => AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: 1.0,
            child: PageView(
              controller: controller.pageController,
              onPageChanged: controller.changeIndex,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildOnboardingPage(
                  context: context,
                  image: TImages.onBoardingImage1,
                  title: TTexts.onBoardingTitle1,
                  subtitle: TTexts.onBoardingSubTitle1,
                  index: 0,
                  currentIndex: controller.currentIndex.value,
                ),
                _buildOnboardingPage(
                  context: context,
                  image: TImages.onBoardingImage2,
                  title: TTexts.onBoardingTitle2,
                  subtitle: TTexts.onBoardingSubTitle2,
                  index: 1,
                  currentIndex: controller.currentIndex.value,
                ),
                _buildOnboardingPage(
                  context: context,
                  image: TImages.onBoardingImage3,
                  title: TTexts.onBoardingTitle3,
                  subtitle: TTexts.onBoardingSubTitle3,
                  index: 2,
                  currentIndex: controller.currentIndex.value,
                ),
              ],
            ),
          )),
          
          // Skip Button with enhanced design
          Positioned(
            top: screenSize.height * 0.05,
            right: TSizes.defaultSpace,
            child: TextButton(
              onPressed: () => controller.skipPage(),
              style: TextButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                backgroundColor: isDark ? Colors.grey.shade800.withOpacity(0.5) : Colors.grey.shade200.withOpacity(0.7),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    TTexts.skip,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Iconsax.arrow_right_3,
                    size: 16,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom navigation area with gradient background
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenSize.height * 0.15,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark 
                    ? [Colors.transparent, Colors.black.withOpacity(0.8)] 
                    : [Colors.transparent, Colors.white.withOpacity(0.9)],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(TSizes.defaultSpace),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Page indicator with custom design
                    SmoothPageIndicator(
                      controller: controller.pageController,
                      count: 3,
                      onDotClicked: controller.dotNavigationClick,
                      effect: ExpandingDotsEffect(
                        activeDotColor: isDark ? Colors.white : TColors.black,
                        dotColor: isDark ? Colors.grey : Colors.grey.shade300,
                        dotHeight: 6,
                        dotWidth: 6,
                        expansionFactor: 4,
                        spacing: 6,
                      ),
                    ),
                    
                    // Next/Get Started button with animation
                    Obx(() => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: controller.currentIndex.value == 2 ? 140 : 60,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () => controller.nextPage(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.white : TColors.black,
                          foregroundColor: isDark ? Colors.black : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(controller.currentIndex.value == 2 ? 30 : 50),
                          ),
                          elevation: 5,
                          shadowColor: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.3),
                          padding: const EdgeInsets.all(0),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: controller.currentIndex.value == 2
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Get Started',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.black : Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Iconsax.arrow_right_3,
                                    size: 16,
                                    color: isDark ? Colors.black : Colors.white,
                                  ),
                                ],
                              )
                            : Icon(
                                Iconsax.arrow_right_3,
                                color: isDark ? Colors.black : Colors.white,
                              ),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Enhanced onboarding page with animations and better layout
  Widget _buildOnboardingPage({
    required BuildContext context,
    required String image,
    required String title,
    required String subtitle,
    required int index,
    required int currentIndex,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final isDark = THelperFunctions.isDarkMode(context);
    final isActive = index == currentIndex;
    
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: TSizes.defaultSpace,
          vertical: screenSize.height * 0.02,
        ),
        child: Column(
          children: [
            // App logo or branding
            Padding(
              padding: EdgeInsets.only(top: screenSize.height * 0.02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.bus,
                    size: 24,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'TrainTicket',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            
            // Animated image with scaling effect
            Expanded(
              flex: 5,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                transform: Matrix4.identity()
                  ..scale(isActive ? 1.0 : 0.9),
                child: Hero(
                  tag: 'onboarding-$index',
                  child: Image(
                    image: AssetImage(image),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            
            // Text content with animations
            Expanded(
              flex: 3,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: isActive ? 1.0 : 0.5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title with animation
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      transform: Matrix4.translationValues(
                        isActive ? 0 : 50, 0, 0,
                      ),
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    
                    // Subtitle with animation
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 700),
                      transform: Matrix4.translationValues(
                        isActive ? 0 : 50, 0, 0,
                      ),
                      child: Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
