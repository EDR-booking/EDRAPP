import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/data/repositories/authentictionrepository.dart';
import 'package:flutter_application_2/features/authentication/screens/email/otpScreen.dart';
import 'package:flutter_application_2/features/authentication/screens/email/userEmailScreen.dart';
import 'package:flutter_application_2/features/settings/screens/language_screen.dart';
import 'package:flutter_application_2/features/settings/screens/localization_demo_screen.dart';
import 'package:flutter_application_2/features/settings/screens/settings_screen.dart';
import 'package:flutter_application_2/firebase_options.dart';
import 'package:flutter_application_2/home.dart';
import 'package:flutter_application_2/utils/theme/theme.dart';
import 'package:flutter_application_2/utils/localization/app_translations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

Future<void> main() async {
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((FirebaseApp value) => Get.put(AuthenticationRepository()));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'app_name'.tr,
      themeMode: ThemeMode.system,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      
      // Localization settings
      translations: AppTranslations(),
      locale: AppTranslations.getCurrentLocale(),
      fallbackLocale: AppTranslations.fallbackLocale,
      
      home: Home(),
      getPages: [
        GetPage(name: '/email', page: () => UserEmailScreen()),
        GetPage(name: '/otp', page: () => OTPScreen()),
        GetPage(name: '/home', page: () => Home()),
        GetPage(name: '/settings', page: () => const SettingsScreen()),
        GetPage(name: '/language', page: () => const LanguageScreen()),
        GetPage(name: '/localization-demo', page: () => const LocalizationDemoScreen()),
      ],
    );
  }
}
