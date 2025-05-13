import 'package:flutter/material.dart';
import 'package:flutter_application_2/utils/constants/sizes.dart';
import 'package:flutter_application_2/utils/widgets/custom_app_bar.dart';
import 'package:get/get.dart';
import '../../controllers/email/email_verification_controller.dart';

class UserEmailScreen extends StatelessWidget {
  UserEmailScreen({super.key});

  final controller = Get.put(EmailVerificationController());
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: CustomAppBar(title: 'email_verification'.tr),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'enter_email_address'.tr,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'email_required'.tr;
                }
                if (!GetUtils.isEmail(value)) {
                  return 'enter_valid_email'.tr;
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'email'.tr,
                hintText: 'enter_email_address'.tr,
                prefixIcon: Icon(Icons.email, 
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
                suffixIcon: emailController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, 
                          color: isDarkMode ? Colors.white70 : null),
                        onPressed: () {
                          emailController.clear();
                          controller.error.value = '';
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            Obx(
              () => controller.error.value.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(
                        bottom: TSizes.spaceBtwItems,
                      ),
                      child: Text(
                        controller.error.value,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (emailController.text.isNotEmpty &&
                      GetUtils.isEmail(emailController.text)) {
                    controller.sendOTP(emailController.text.trim());
                  } else {
                    controller.error.value = 'enter_valid_email'.tr;
                  }
                },
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : Text('verify'.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
