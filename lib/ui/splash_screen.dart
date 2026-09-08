
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class splashScreen extends StatefulWidget {
  const splashScreen({super.key});

  @override
  State<splashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<splashScreen> {

  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  Future<void> _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    Get.offNamed(
      '/LoginScreen',
      arguments: 'Login Screen',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorsList.colorGray_50,

      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Image.asset(
            'assets/main_logo.png',
            width: MediaQuery.of(context).size.width * 0.55,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}