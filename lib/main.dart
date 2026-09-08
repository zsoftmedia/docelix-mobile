import 'package:docelix_mobileapp/introPages/Intro_screen.dart';
import 'package:docelix_mobileapp/ui/add_client_screen.dart';
import 'package:docelix_mobileapp/ui/clients_screen.dart';
import 'package:docelix_mobileapp/ui/create_invoices_screen.dart';
import 'package:docelix_mobileapp/ui/dashboard_screen.dart';
import 'package:docelix_mobileapp/ui/invoices_screen.dart';
import 'package:docelix_mobileapp/ui/land_screen.dart';
import 'package:docelix_mobileapp/ui/ui_auth/login_screen.dart';
import 'package:docelix_mobileapp/ui/ui_auth/signup_screen.dart';
import 'package:docelix_mobileapp/ui/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get_storage/get_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
          ? const splashScreen()
          : const IntroScreen(),

      getPages: [
        GetPage(name: '/SplashScreen', page: () => const splashScreen(),),
        GetPage(name: '/LoginScreen', page: () => LoginScreen(),),
        GetPage(name: '/RegisterScreen', page: () => SignUpScreen(),),
        GetPage(name: '/LandScreen', page: () => LandScreen(),),
        GetPage(name: '/DashboardScreen', page: () => DashboardScreen(),),
        GetPage(name: '/InvoicesScreen', page: () => InvoicesScreen(),),
        GetPage(name: '/CreateInvoicesScreen', page: () => CreateInvoicesScreen(),),
        GetPage(name: '/ClientsScreen', page: () => ClientsScreen(),),
        GetPage(name: '/AddClientScreen', page: () => AddClientScreen(),),
      ],
    );
  }
}
