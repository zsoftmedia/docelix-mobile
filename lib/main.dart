import 'package:docelix_mobileapp/introPages/Intro_screen.dart';
import 'package:docelix_mobileapp/models/incoming_invoices_model.dart';
import 'package:docelix_mobileapp/ui/add_client_screen.dart';
import 'package:docelix_mobileapp/ui/catalogs_screen.dart';
import 'package:docelix_mobileapp/ui/client_details_screen.dart';
import 'package:docelix_mobileapp/ui/clients_screen.dart';
import 'package:docelix_mobileapp/ui/create_incoming_invoices_screen.dart';
import 'package:docelix_mobileapp/ui/dashboard_screen.dart';
import 'package:docelix_mobileapp/ui/incoming_invoices_details_screen.dart';
import 'package:docelix_mobileapp/ui/incoming_invoices_screen.dart';
import 'package:docelix_mobileapp/ui/invoices_details_screen.dart';
import 'package:docelix_mobileapp/ui/invoices_screen.dart';
import 'package:docelix_mobileapp/ui/land_screen.dart';
import 'package:docelix_mobileapp/ui/ui_auth/login_screen.dart';
import 'package:docelix_mobileapp/ui/ui_auth/signup_screen.dart';
import 'package:docelix_mobileapp/ui/splash_screen.dart';
import 'package:docelix_mobileapp/config/api_constants.dart';
import 'package:docelix_mobileapp/ui/voice_recognition_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: ApiConstants.supabaseUrl,
    anonKey: ApiConstants.supabaseAnonKey,
  );

  await GetStorage.init();

  final box = GetStorage();

  final bool introCompleted =
      box.read('intro_completed') ?? false;

  runApp(
    MyApp(
      introCompleted: introCompleted,
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool introCompleted;

  const MyApp({
    super.key,
    required this.introCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      // First time → Intro
      // Already completed → Splash
      home: introCompleted
          ? const SplashScreen()
          : const IntroScreen(),

      getPages: [
        GetPage(name: '/SplashScreen', page: () => const SplashScreen(),),
        GetPage(name: '/LoginScreen', page: () => LoginScreen(),),
        GetPage(name: '/RegisterScreen', page: () => SignUpScreen(),),
        GetPage(name: '/LandScreen', page: () => LandScreen(),),
        GetPage(name: '/DashboardScreen', page: () => DashboardScreen(),),
        GetPage(name: '/IncomingInvoicesScreen', page: () => IncomingInvoicesScreen(),),
        GetPage(name: '/CreateIncomingInvoicesScreen', page: () => CreateIncomingInvoicesScreen(),),
        GetPage(name: '/ClientsScreen', page: () => ClientsScreen(),),
        GetPage(name: '/ClientDetailsScreen', page: () => ClientDetailsScreen(),),
        GetPage(name: '/AddClientScreen', page: () => AddClientScreen(),),
        GetPage(name: '/IncomingInvoicesDetailsScreen', page: () => IncomingInvoicesDetailsScreen(invoice: Get.arguments as IncomingInvoicesModel),),
        GetPage(name: '/InvoicesScreen', page: () => InvoicesScreen(),),
        GetPage(name: '/InvoicesDetailsScreen', page: () => InvoicesDetailsScreen(),),
        GetPage(name: '/VoiceRecognitionScreen', page: () => VoiceRecognitionScreen(),),
        // Items List Screen ==> Catalogs Screen
        GetPage(name: '/CatalogsScreen', page: () => CatalogsScreen(),),
      ],
    );
  }
}
