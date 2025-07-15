import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/data/repositories/authentictionrepository.dart';
import 'package:flutter_application_2/features/settings/screens/language_screen.dart';
import 'package:flutter_application_2/features/settings/screens/localization_demo_screen.dart';
import 'package:flutter_application_2/features/settings/screens/settings_screen.dart';
import 'package:flutter_application_2/features/ticket/controllers/ticketController.dart';
import 'package:flutter_application_2/features/ticket/screen/ticketScreen.dart';
import 'package:flutter_application_2/firebase_options.dart';
import 'package:flutter_application_2/home.dart';
import 'package:flutter_application_2/utils/theme/theme.dart';
import 'package:flutter_application_2/utils/localization/app_translations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage for local storage
  await GetStorage.init();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((FirebaseApp value) => Get.put(AuthenticationRepository()));

  // Initialize Supabase
  final supabaseUrl = const String.fromEnvironment('SUPABASE_URL', 
      defaultValue: 'https://qswnxymdeolgpqliaedc.supabase.co');
  final supabaseAnonKey = const String.fromEnvironment('SUPABASE_ANON_KEY',
      defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFzd254eW1kZW9sZ3BxbGlhZWRjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY2MTQ3MjUsImV4cCI6MjA2MjE5MDcyNX0.FcWVoO39GHZrZHemjhYYlJCYLs1FOsJe_gXC3RIBo9o');
  
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(MyApp());
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
        GetPage(name: '/home', page: () => Home()),
        GetPage(name: '/ticket', page: () => TicketScreen(selectedCitizenship: 'Ethiopian')),
        GetPage(name: '/settings', page: () => const SettingsScreen()),
        GetPage(name: '/language', page: () => const LanguageScreen()),
        GetPage(name: '/localization-demo', page: () => const LocalizationDemoScreen()),
      ],
    );
  }
}
