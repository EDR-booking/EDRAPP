import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/authentication/controllers/email/otp_controller.dart';
import 'package:flutter_application_2/utils/constants/sizes.dart';
import 'package:flutter_application_2/utils/widgets/custom_app_bar.dart';
import 'package:get/get.dart';

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: CustomAppBar(title: 'otp_verification'.tr),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Obx(() => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('enter_otp'.tr, 
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: isDarkMode ? Colors.white : null,
              )
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            Text(
              'verification_code_sent'.tr + ' ${email}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isDarkMode ? Colors.white70 : null,
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            // Timer display
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: controller.hasExpired.value 
                  ? (isDarkMode 
                      ? Colors.red.shade900.withOpacity(0.3) 
                      : Colors.red.shade100)
                  : (isDarkMode 
                      ? Colors.blue.shade900.withOpacity(0.3) 
                      : Colors.blue.shade50),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer,
                    color: controller.hasExpired.value 
                        ? (isDarkMode 
                            ? Colors.red.shade300 
                            : Colors.red)
                        : (isDarkMode 
                            ? Colors.blue.shade300 
                            : Colors.blue),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    controller.hasExpired.value
                        ? 'invalid_otp'.tr
                        : 'expires_in'.tr + ' $_timerText',
                    style: TextStyle(
                      color: controller.hasExpired.value 
                        ? (isDarkMode 
                            ? Colors.red.shade300 
                            : Colors.red.shade800)
                        : (isDarkMode 
                            ? Colors.blue.shade300 
                            : Colors.blue.shade800),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            TextFormField(
              controller: controller.otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: 'enter_otp'.tr,
                hintText: 'enter_otp'.tr,
                prefixIcon: Icon(Icons.lock, 
                  color: isDarkMode ? Colors.white70 : null),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isDarkMode ? Colors.grey[600]! : Colors.grey,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isDarkMode ? Colors.grey[600]! : Colors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                labelStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : null,
                ),
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : null,
                ),
                filled: isDarkMode,
                fillColor: isDarkMode ? Colors.grey[800] : null,
                errorText: controller.errorMessage.value.isNotEmpty ? controller.errorMessage.value : null,
                errorStyle: TextStyle(
                  color: Colors.red[400],
                ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isVerifying.value ? null : () async {
                  await controller.verifyOTP();
                },
                child: controller.isVerifying.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('verify'.tr),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            TextButton.icon(
              onPressed: controller.isResending.value ? null : () async {
                await controller.resendOTP();
                _resetTimer();
                controller.hasExpired.value = false;
              },
              icon: controller.isResending.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    )
                  : Icon(Icons.refresh, color: isDarkMode ? Colors.white70 : Colors.blue),
              label: Text(
                'resend_otp'.tr,
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.blue,
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }
}
