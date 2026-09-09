import 'package:docelix_mobileapp/services/auth_services.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class LoginController extends GetxController {

  final authService = AuthServices();
  final dioClient = DioClient();

  final isLoading = false.obs;

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  void login () async {

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Validation',
        'Please enter email and password.',
      );
      return;
    }

    try{
      isLoading.value = true;
      // await authService.signInWithEmailPassword(email, password);
      final response = await authService.signInWithEmailPassword(
        email,
        password,
      );

      // GET SESSION
      final Session? session = response.session;

      if (session == null) {

        Get.snackbar(
          'Login Failed',
          'Unable to create a session.',
        );

        return;
      }
      // GET USER
      final User user = session.user;

      // GET SUPABASE ACCESS TOKEN
      final String accessToken = session.accessToken;

      // DEBUG ONLY
      debugPrint('================================');
      debugPrint('SUPABASE LOGIN SUCCESS');
      debugPrint('User ID: ${user.id}');
      debugPrint('Email: ${user.email}');
      debugPrint('Access Token: $accessToken');
      debugPrint('================================');


    }on AuthException catch (e) {

      // Supabase authentication error
      isLoading.value = false;

      debugPrint('Supabase Auth Error: ${e.message}');

      Get.snackbar('Login Failed', e.message,);

      debugPrint('================================');
      debugPrint('SUPABASE AUTH ERROR');
      debugPrint('Message: ${e.message}');
      debugPrint('Status Code: ${e.statusCode}');
      debugPrint('Code: ${e.code}');
      debugPrint('================================');

    } catch(e) {

      isLoading.value = false;

      Get.snackbar(
        'Failed',
        'Something went wrong $e',
      );

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