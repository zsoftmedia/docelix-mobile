import 'package:docelix_mobileapp/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupController extends GetxController {
  final authService = AuthServices();

  final isLoading = false.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> signUp() async {
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Validation',
        'Please enter email and password.',
      );
      return;
    }

    if (password.length < 8) {
      Get.snackbar(
        'Validation',
        'Password must be at least 8 characters.',
      );
      return;
    }

    try {
      isLoading.value = true;

      final response = await authService.signUpWithEmailPassword(
        email,
        password,
      );

      debugPrint('================================');
      debugPrint('SUPABASE SIGNUP');
      debugPrint('Email: $email');
      debugPrint('User ID: ${response.user?.id}');
      debugPrint('Session: ${response.session != null}');
      debugPrint('Email confirmed: ${response.user?.emailConfirmedAt}');
      debugPrint('================================');

      if (response.session != null) {
        Get.snackbar('Success', 'Account created.');
        Get.offNamed(
          '/LandScreen',
          arguments: 'Land Screen',
        );
        return;
      }

      Get.snackbar(
        'Confirm your email',
        'Account created, but this project requires email confirmation. '
            'Open Supabase → Authentication → Users, confirm this email, then log in.',
        duration: const Duration(seconds: 8),
      );
    } on AuthException catch (e) {
      debugPrint('================================');
      debugPrint('SUPABASE SIGNUP ERROR');
      debugPrint('Message: ${e.message}');
      debugPrint('Status Code: ${e.statusCode}');
      debugPrint('Code: ${e.code}');
      debugPrint('================================');

      Get.snackbar('Sign up failed', e.message);
    } catch (e) {
      Get.snackbar('Failed', 'Something went wrong $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
