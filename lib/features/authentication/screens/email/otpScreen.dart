import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/features/authentication/controllers/email/otp_controller.dart';
import 'package:flutter_application_2/utils/constants/sizes.dart';
import 'package:flutter_application_2/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  late OTPController controller;
  late String email;
  
  // Timer for OTP expiration (2 minutes)
  int _remainingSeconds = 120; // 2 minutes in seconds
  Timer? _timer;
  
  @override
  void initState() {
    super.initState();
    // Safely get arguments
    email = Get.arguments is String ? Get.arguments as String : '';
    
    // Initialize controller
    controller = Get.put(OTPController());
    controller.email.value = email;
    
    // Print debug info
    print('OTP Screen initialized with email: $email');
    
    _startTimer();
  }
  
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          // OTP has expired
          controller.hasExpired.value = true;
        }
      });
    });
  }
  
  void _resetTimer() {
    setState(() {
      _remainingSeconds = 120; // Reset to 2 minutes
      if (_timer != null) {
        _timer!.cancel();
      }
      _startTimer();
    });
  }
  
  String get _timerText {
    final minutes = (_remainingSeconds / 60).floor();
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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
            child: Obx(() => Column(
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
                      'otp_verification'.tr,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                
                // OTP verification illustration
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(TSizes.md),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade900.withOpacity(0.5) : Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Iconsax.security_safe,
                        size: 80,
                        color: isDark ? Colors.blue.shade200 : Colors.blue.shade700,
                      ),
                    ),
                  ),
                ),
                
                // OTP verification content
                Expanded(
                  flex: 7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and subtitle
                      Text(
                        'enter_otp'.tr,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: TSizes.sm),
                      Text(
                        'verification_code_sent'.tr + ' ${email}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      
                      // Timer display with enhanced design
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: controller.hasExpired.value 
                            ? (isDark 
                                ? Colors.red.shade900.withOpacity(0.2) 
                                : Colors.red.shade50)
                            : (isDark 
                                ? Colors.blue.shade900.withOpacity(0.2) 
                                : Colors.blue.shade50),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: controller.hasExpired.value
                              ? (isDark 
                                  ? Colors.red.shade800.withOpacity(0.3) 
                                  : Colors.red.shade200)
                              : (isDark 
                                  ? Colors.blue.shade800.withOpacity(0.3) 
                                  : Colors.blue.shade200),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              controller.hasExpired.value ? Iconsax.timer_1 : Iconsax.timer,
                              color: controller.hasExpired.value 
                                  ? (isDark 
                                      ? Colors.red.shade300 
                                      : Colors.red.shade700)
                                  : (isDark 
                                      ? Colors.blue.shade300 
                                      : Colors.blue.shade700),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              controller.hasExpired.value
                                  ? 'invalid_otp'.tr
                                  : 'expires_in'.tr + ' $_timerText',
                              style: TextStyle(
                                color: controller.hasExpired.value 
                                  ? (isDark 
                                      ? Colors.red.shade300 
                                      : Colors.red.shade700)
                                  : (isDark 
                                      ? Colors.blue.shade300 
                                      : Colors.blue.shade700),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: TSizes.spaceBtwSections),
                      
                      // OTP input field with enhanced design
                      Container(
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
                          controller: controller.otpController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 18,
                            letterSpacing: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: '000000',
                            counterText: '',
                            prefixIcon: Icon(
                              Iconsax.security_card,
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
                              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                              letterSpacing: 8,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: TSizes.md,
                              vertical: TSizes.md,
                            ),
                            errorText: controller.errorMessage.value.isNotEmpty ? controller.errorMessage.value : null,
                            errorStyle: TextStyle(
                              color: isDark ? Colors.red.shade300 : Colors.red.shade700,
                              fontSize: 12,
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: isDark ? Colors.red.shade300 : Colors.red.shade700,
                                width: 1.5,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: isDark ? Colors.red.shade300 : Colors.red.shade700,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Verify button with enhanced design
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: controller.isVerifying.value ? null : () async {
                            await controller.verifyOTP();
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
                            disabledBackgroundColor: isDark 
                              ? Colors.grey.shade800 
                              : Colors.grey.shade300,
                          ),
                          child: controller.isVerifying.value
                              ? SizedBox(
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
                                    const Icon(Iconsax.tick_circle, size: 18),
                                  ],
                                ),
                        ),
                      ),
                      
                      // Resend OTP button with enhanced design
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: TSizes.md),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton.icon(
                              onPressed: controller.isResending.value ? null : () async {
                                await controller.resendOTP();
                                _resetTimer();
                                controller.hasExpired.value = false;
                              },
                              icon: controller.isResending.value
                                  ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          isDark ? Colors.blue.shade200 : Colors.blue.shade700,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      Iconsax.refresh,
                                      size: 16,
                                      color: isDark ? Colors.blue.shade200 : Colors.blue.shade700,
                                    ),
                              label: Text(
                                'resend_otp'.tr,
                                style: TextStyle(
                                  color: isDark ? Colors.blue.shade200 : Colors.blue.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: TSizes.md,
                                  vertical: TSizes.sm,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
          ),
        ),
      ),
    );
  }
}
