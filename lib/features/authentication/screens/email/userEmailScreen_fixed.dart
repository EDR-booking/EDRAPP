import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/utils/constants/colors.dart';
import 'package:flutter_application_2/utils/constants/sizes.dart';
import 'package:flutter_application_2/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../controllers/email/email_verification_controller.dart';

class UserEmailScreen extends StatelessWidget {
  UserEmailScreen({super.key});

  final controller = Get.put(EmailVerificationController());
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    final size = MediaQuery.of(context).size;
    
    // Set system overlay style based on theme
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: size.height - MediaQuery.of(context).padding.top,
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button and title
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Iconsax.arrow_left,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: TSizes.sm),
                    Text(
                      'email_verification'.tr,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                
                // Email verification illustration
                Expanded(
                  flex: 4,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(TSizes.md),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade900.withOpacity(0.5) : Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Iconsax.message_notif,
                        size: 100,
                        color: isDark ? Colors.blue.shade200 : Colors.blue.shade700,
                      ),
                    ),
                  ),
                ),
                
                // Email verification content
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and subtitle
                      Text(
                        'enter_email_address'.tr,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: TSizes.sm),
                      Text(
                        'verification_email_subtitle'.tr,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      
                      // Email input field with animation
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: isDark 
                                ? Colors.black.withOpacity(0.3) 
                                : Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: 'enter_email_address'.tr,
                            prefixIcon: Icon(
                              Iconsax.message,
                              color: isDark ? Colors.blue.shade200 : Colors.blue.shade700,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: isDark ? Colors.blue.shade200 : Colors.blue.shade700,
                                width: 1.5,
                              ),
                            ),
                            hintStyle: TextStyle(
                              color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: TSizes.md,
                              vertical: TSizes.md,
                            ),
                            suffixIcon: emailController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Iconsax.close_circle,
                                      color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
                                    ),
                                    onPressed: () {
                                      emailController.clear();
                                      controller.error.value = '';
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (value) {
                            // Force rebuild to show/hide clear button
                            (context as Element).markNeedsBuild();
                          },
                        ),
                      ),
                      
                      // Error message
                      Obx(
                        () => controller.error.value.isNotEmpty
                            ? Container(
                                margin: const EdgeInsets.only(
                                  top: TSizes.sm,
                                  bottom: TSizes.sm,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: TSizes.md,
                                  vertical: TSizes.sm,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark 
                                    ? Colors.red.shade900.withOpacity(0.3) 
                                    : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark 
                                      ? Colors.red.shade800.withOpacity(0.5) 
                                      : Colors.red.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Iconsax.warning_2,
                                      color: isDark ? Colors.red.shade300 : Colors.red.shade700,
                                      size: 18,
                                    ),
                                    const SizedBox(width: TSizes.sm),
                                    Expanded(
                                      child: Text(
                                        controller.error.value,
                                        style: TextStyle(
                                          color: isDark ? Colors.red.shade300 : Colors.red.shade700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      
                      const Spacer(),
                      
                      // Verify button
                      Obx(() {
                        return SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            // Disable button when loading or cooldown active
                            onPressed: controller.isLoading.value || controller.isCooldownActive.value
                                ? null // Disable when loading or cooldown active
                                : () {
                                    if (emailController.text.isNotEmpty &&
                                        GetUtils.isEmail(emailController.text)) {
                                      controller.sendOTP(emailController.text.trim());
                                    } else {
                                      controller.error.value = 'enter_valid_email'.tr;
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? Colors.blue.shade700 : Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              elevation: 5,
                              shadowColor: isDark 
                                ? Colors.blue.shade900.withOpacity(0.5) 
                                : Colors.blue.shade300.withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: controller.isLoading.value
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'verify'.tr,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: TSizes.sm),
                                      const Icon(Iconsax.arrow_right_3, size: 18),
                                    ],
                                  ),
                          ),
                        );
                      }),
                      
                      // Security note
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: TSizes.md),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.shield_tick,
                              size: 14,
                              color: isDark ? Colors.grey.shade500 : Colors.grey.shade700,
                            ),
                            const SizedBox(width: TSizes.xs),
                            Text(
                              'secure_verification'.tr,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.grey.shade500 : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
